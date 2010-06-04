//
//  RTMAPITask.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPITask.h"
#import "RTMAPI.h"
#import "RTMTask.h"
#import "RTMNote.h"
#import "RTMAPIParserDelegate.h"
#import "logger.h"

/* -------------------------------------------------------------------
 * TaskGetListCallback
 */
@interface TaskGetListCallback : RTMAPIParserDelegate
{
   enum state_t {
      TAG,
      NOTE,
      RRULE
   } mode;

   NSString *list_id;
   NSMutableArray *tasks;
   NSMutableArray *tags;
   NSString *tag;
   NSMutableArray *notes;
   NSMutableArray *task_entries;
   NSMutableDictionary *note;
   NSString *note_str;
   NSMutableDictionary *taskseries;
}
@end // TaskGetListCallback

@implementation TaskGetListCallback

- (id) init
{
   if (self = [super init]) {
      list_id = nil;
      tasks = nil;
      tags = nil;
      tag = nil;
      notes = nil;
      task_entries = nil;
      note = nil;
      note_str = nil;
      taskseries = nil;
   }
   return self;
}

- (NSArray *) tasks
{
   return tasks;
}

/*
 * construct taskseries array of NSStrings.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

   if ([elementName isEqualToString:@"tasks"]) {
      tasks = [NSMutableArray array];
   } else if ([elementName isEqualToString:@"list"]) {
      list_id = [attributeDict valueForKey:@"id"];
   } else  if ([elementName isEqualToString:@"taskseries"]) {
      taskseries = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      [taskseries setObject:list_id forKey:@"list_id"];
      task_entries = [NSMutableArray array];
      [taskseries setObject:task_entries forKey:@"tasks"];
      [tasks addObject:taskseries];
   } else if ([elementName isEqualToString:@"tags"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      tags = [NSMutableArray array];
      [taskseries setObject:tags forKey:@"tags"];
   } else if ([elementName isEqualToString:@"tag"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      NSAssert(tags, @"should be in tags element");
      tag = @"";
      mode = TAG;
   } else if ([elementName isEqualToString:@"notes"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      notes = [NSMutableArray array];
      [taskseries setObject:notes forKey:@"notes"];
   } else if ([elementName isEqualToString:@"note"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      NSAssert(notes, @"should be in notes element");
      mode = NOTE;
      note = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      note_str = @"";
      [notes addObject:note];
   } else if ([elementName isEqualToString:@"rrule"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      mode = RRULE;
   } else if ([elementName isEqualToString:@"task"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      NSAssert(task_entries, @"should be in taskseries element");
      [task_entries addObject:attributeDict];
   }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"taskseries"]) {
      taskseries = nil;
      task_entries = nil;
   } else if ([elementName isEqualToString:@"tags"]) {
      tags = nil;
   } else if ([elementName isEqualToString:@"tag"]) {
      NSAssert(tags, @"should be in tags");
      [tags addObject:tag];
      tag = nil;
   } else if ([elementName isEqualToString:@"notes"]) {
      notes = nil;
   } else if ([elementName isEqualToString:@"note"]) {
      if (! [note_str isEqualToString:@""])
         [note setObject:note_str forKey:@"text"];
      note = nil;
      note_str = nil;
   }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   // check whethere chars contains white space only.
   const char *str = [chars UTF8String];
   int i=0, len=[chars length];
   for (; i<len; i++)
      if (! isspace(str[i])) break;
   if (i == len) return;

   switch (mode) {
      case TAG:
         NSAssert(tags, @"should be in tags");
         tag = [tag stringByAppendingString:chars];
         break;
      case NOTE:
         NSAssert(notes, @"should be in notes");
         NSAssert(note, @"should be in note");
         note_str = [note_str stringByAppendingString:chars];
         break;
      case RRULE:
         [taskseries setObject:chars forKey:@"rrule"];
         break;
      default:
         NSAssert(NO, @"should not reach here");
         break;
   }
}

@end // TaskGetListCallback

/* -------------------------------------------------------------------
 * TaskListAddCallback
 */
@interface TaskListAddCallback : RTMAPIParserDelegate
{
   NSMutableDictionary *ids;
}
@end

@implementation TaskListAddCallback

- (NSDictionary *) ids
{
   return ids;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

   if ([elementName isEqualToString:@"list"]) {
      ids = [NSMutableDictionary dictionary];
      [ids setObject:[attributeDict valueForKey:@"id"] forKey:@"list_id"];
   } else if ([elementName isEqualToString:@"taskseries"]) {
      [ids setObject:[attributeDict valueForKey:@"id"] forKey:@"taskseries_id"];
   } else if ([elementName isEqualToString:@"task"]) {
      [ids setObject:[attributeDict valueForKey:@"id"] forKey:@"task_id"];
   }
}
@end

/* -------------------------------------------------------------------
 * RTMAPITask
 */
@implementation RTMAPITask

- (NSArray *) getList_internal:(NSDictionary *)args
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   NSData *response = [api call:@"rtm.tasks.getList" withArgs:args];
   if (! response) return nil;

   method = TASKS_GETLIST;
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   TaskGetListCallback *cb = [[[TaskGetListCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"getList failed : %@", [cb.error localizedDescription]);
      return nil;
   }
   return [cb tasks];
}

- (NSArray *) getList
{
   return [self getList_internal:nil];
}

- (NSArray *) getListForList:(NSString *)list_id
{
   NSDictionary *args = [NSDictionary dictionaryWithObject:list_id forKey:@"list_id"];
   return [self getList_internal:args];
}	

- (NSArray *) getListWithLastSync:(NSString *)last_sync
{
   NSDictionary *args = [NSDictionary dictionaryWithObject:last_sync forKey:@"last_sync"];
   return [self getList_internal:args];
}	

- (NSArray *) getListForList:(NSString *)list_id withLastSync:(NSString *)last_sync
{
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"last_sync", nil];
   NSArray *vals = [NSArray arrayWithObjects:list_id, last_sync, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return [self getList_internal:args];
}	

- (NSDictionary *) add:(NSString *)name inList:(NSString *)list_id withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"name", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:name, timeLine, nil];
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   if (list_id)
      [args setObject:list_id forKey:@"list_id"];

   NSData *response = [api call:@"rtm.tasks.add" withArgs:args];
   if (! response) return nil;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   TaskListAddCallback *cb = [[[TaskListAddCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"add failed : %@", [cb.error localizedDescription]);
      return nil;
   }
   return [cb ids];
}

- (BOOL) delete:(NSString *)task_id inTaskSeries:(NSString *)taskseries_id inList:(NSString *)list_id withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeLine, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.delete" withArgs:args];
   if (! response) return NO;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"delete failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

- (BOOL) setDue:(NSString *)due forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"due", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [ids objectForKey:@"list_id"],
      [ids objectForKey:@"taskseries_id"],
      [ids objectForKey:@"task_id"],
      timeLine,
      due,
      nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.setDueDate" withArgs:args];
   if (! response) return NO;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"setDueDate failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

- (BOOL) setLocation:(NSString *)location_id forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"location_id", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [ids objectForKey:@"list_id"],
      [ids objectForKey:@"taskseries_id"],
      [ids objectForKey:@"task_id"],
      timeLine,
      location_id,
      nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.setLocation" withArgs:args];
   if (! response) return NO;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"setLocation failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

- (BOOL) setPriority:(NSString *)priority forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"priority", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [ids objectForKey:@"list_id"],
      [ids objectForKey:@"taskseries_id"],
      [ids objectForKey:@"task_id"],
      timeLine,
      priority,
      nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.setPriority" withArgs:args];
   if (! response) return NO;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"setPriority failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

- (BOOL) setEstimate:(NSString *)estimate forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"estimate", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [ids objectForKey:@"list_id"],
      [ids objectForKey:@"taskseries_id"],
      [ids objectForKey:@"task_id"],
      timeLine,
      estimate,
      nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.setEstimate" withArgs:args];
   if (! response) return NO;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"setEstimate failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

- (BOOL) complete:(RTMTask *)task withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:
      [task.list_id stringValue],
      [task.taskseries_id stringValue],
      [task.task_id stringValue],
      timeLine,
      nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.complete" withArgs:args];
   if (! response) return NO;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"complete failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

- (BOOL) setTags:(NSString *)tags forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   
   NSArray *keys = [NSArray arrayWithObjects:@"tags", @"list_id", @"taskseries_id", @"task_id",  @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:
                    tags,
                    [ids objectForKey:@"list_id"],
                    [ids objectForKey:@"taskseries_id"],
                    [ids objectForKey:@"task_id"],
                    timeLine,
                    nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   NSData *response = [api call:@"rtm.tasks.setTags" withArgs:args];
   if (! response) return NO;
   
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"complete failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;   
}

- (BOOL) moveTo:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:ids];
   [args setObject:timeLine forKey:@"timeline"];
   
   NSData *response = [api call:@"rtm.tasks.moveTo" withArgs:args];
   if (! response) return NO;
   
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"moveTo failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;   
}

- (BOOL) setName:(NSString *)name forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:ids];
   [args setObject:timeLine forKey:@"timeline"];
   [args setObject:name forKey:@"name"];
   
   NSData *response = [api call:@"rtm.tasks.setName" withArgs:args];
   if (! response) return NO;
   
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"setName failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;   
}
@end
