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
#import "RTMAPIXMLParserCallback.h"

/* -------------------------------------------------------------------
 * TaskGetListCallback
 */
@interface TaskGetListCallback : RTMAPIXMLParserCallback
{
  enum state_t {
    TAG,
    NOTE,
    RRULE
  } mode;
  
  NSString *list_id;
  NSMutableArray *tasks;
  NSMutableArray *tags;
  NSMutableArray *notes;
  NSMutableArray *task_entries;
  NSMutableDictionary *note;
  NSMutableDictionary *task_series;
  NSMutableDictionary *rrule;
}
@end

@implementation TaskGetListCallback

- (NSArray *) tasks {
  return tasks;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
  [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

  if ([elementName isEqualToString:@"tasks"]) {
    tasks = [NSMutableArray array];
  } else if ([elementName isEqualToString:@"list"]) {
    list_id = [attributeDict valueForKey:@"id"];
  } else  if ([elementName isEqualToString:@"taskseries"]) {
    task_series = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
    [task_series setObject:list_id forKey:@"list_id"];
    task_entries = [NSMutableArray array];
    [task_series setObject:task_entries forKey:@"tasks"];
    [tasks addObject:task_series];
  } else if ([elementName isEqualToString:@"tags"]) {
    NSAssert(task_series, @"should be in taskseries element");
    tags = [NSMutableArray array];
    [task_series setObject:tags forKey:@"tags"];
  } else if ([elementName isEqualToString:@"tag"]) {
    NSAssert(task_series, @"should be in taskseries element");
    NSAssert(tags, @"should be in tags element");
    mode = TAG;
  } else if ([elementName isEqualToString:@"notes"]) {
    NSAssert(task_series, @"should be in taskseries element");
    notes = [NSMutableArray array];
    [task_series setObject:notes forKey:@"notes"];
	} else if ([elementName isEqualToString:@"note"]) {
    NSAssert(task_series, @"should be in taskseries element");
    NSAssert(notes, @"should be in notes element");
    mode = NOTE;
    note = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
    [notes addObject:note];
  } else if ([elementName isEqualToString:@"rrule"]) {
    NSAssert(task_series, @"should be in taskseries element");
    mode = RRULE;
    rrule = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
    [task_series setObject:rrule forKey:@"rrule"];
  } else if ([elementName isEqualToString:@"task"]) {
    NSAssert(task_series, @"should be in taskseries element");
    NSAssert(task_entries, @"should be in taskseries element");
    [task_entries addObject:attributeDict];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"taskseries"]) {
    task_series = nil;
    task_entries = nil;
  } else if ([elementName isEqualToString:@"tags"]) {
    tags = nil;
  } else if ([elementName isEqualToString:@"notes"]) {
    notes = nil;
	} else if ([elementName isEqualToString:@"note"]) {
    note = nil;
  } else if ([elementName isEqualToString:@"rrule"]) {
    rrule = nil;
	}
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars {
  switch (mode) {
    case TAG:
      NSAssert(tags, @"should be in tags");
      [tags addObject:chars];
      break;
    case NOTE:
      NSAssert(notes, @"should be in notes");
      NSAssert(note, @"should be in note");
      [note setObject:chars forKey:@"text"];
      break;
    case RRULE:
      NSAssert(rrule, @"should be in rrule");
      [rrule setObject:chars forKey:@"rule"];
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
@interface TaskListAddCallback : RTMAPIXMLParserCallback
{
  NSMutableDictionary *ids;
}
@end

@implementation TaskListAddCallback

- (NSDictionary *) ids {
  return ids;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
  [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

  if ([elementName isEqualToString:@"list"]) {
    ids = [NSMutableDictionary dictionary];
    [ids setObject:[attributeDict valueForKey:@"id"] forKey:@"list_id"];
  } else if ([elementName isEqualToString:@"taskseries"]) {
    [ids setObject:[attributeDict valueForKey:@"id"] forKey:@"task_series_id"];
  } else if ([elementName isEqualToString:@"task"]) {
    [ids setObject:[attributeDict valueForKey:@"id"] forKey:@"task_id"];
  }
}
@end

/* -------------------------------------------------------------------
 * RTMAPITask
 */
@implementation RTMAPITask

- (NSArray *) getList_internal:(NSDictionary *)args {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSData *response = [api call:@"rtm.tasks.getList" withArgs:args];
  if (! response) return nil;
  
  method = TASKS_GETLIST;
  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
  TaskGetListCallback *cb = [[[TaskGetListCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"getList failed : %@", [cb.error localizedDescription]);
    return nil;
  }
  return [cb tasks];
}

- (NSArray *) getList {
  return [self getList_internal:nil];
}

- (NSArray *) getListForList:(NSString *)list_id {
	NSDictionary *args = [NSDictionary dictionaryWithObject:list_id forKey:@"list_id"];
  return [self getList_internal:args];
}	

- (NSArray *) getListWithLastSync:(NSString *)last_sync {
	NSDictionary *args = [NSDictionary dictionaryWithObject:last_sync forKey:@"last_sync"];
  return [self getList_internal:args];
}	

- (NSArray *) getListForList:(NSString *)list_id withLastSync:(NSString *)last_sync {
  NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"last_sync", nil];
  NSArray *vals = [NSArray arrayWithObjects:list_id, last_sync, nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
  return [self getList_internal:args];
}	

- (NSDictionary *) add:(NSString *)name inList:(NSString *)list_id {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return nil;

	NSArray *keys = [NSArray arrayWithObjects:@"name", @"timeline", nil];
	NSArray *vals = [NSArray arrayWithObjects:name, timeline, nil];
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
    NSLog(@"add failed : %@", [cb.error localizedDescription]);
    return nil;
  }
  return [cb ids];
}

- (BOOL) delete:(NSString *)task_id inTaskSeries:(NSString *)task_series_id inList:(NSString *)list_id {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return NO;

	NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", nil];
	NSArray *vals = [NSArray arrayWithObjects:list_id, task_series_id, task_id, timeline, nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

	NSData *response = [api call:@"rtm.tasks.delete" withArgs:args];
  if (! response) return NO;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
  RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"delete failed : %@", [cb.error localizedDescription]);
    return NO;
  }
  return YES;
}

- (BOOL) setDue:(NSString *)due forIDs:(NSDictionary *)ids {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return NO;

	NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"due", nil];
	NSArray *vals = [NSArray arrayWithObjects:
    [ids objectForKey:@"list_id"],
    [ids objectForKey:@"task_series_id"],
    [ids objectForKey:@"task_id"],
    timeline,
    due,
    nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

	NSData *response = [api call:@"rtm.tasks.setDueDate" withArgs:args];
  if (! response) return NO;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
  RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"setDueDate failed : %@", [cb.error localizedDescription]);
    return NO;
  }
  return YES;
}

- (BOOL) setLocation:(NSInteger)location_id forIDs:(NSDictionary *)ids {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return NO;

	NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"location_id", nil];
	NSArray *vals = [NSArray arrayWithObjects:
    [ids objectForKey:@"list_id"],
    [ids objectForKey:@"task_series_id"],
    [ids objectForKey:@"task_id"],
    timeline,
    [NSString stringWithFormat:@"%d", location_id],
    nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

	NSData *response = [api call:@"rtm.tasks.setLocation" withArgs:args];
  if (! response) return NO;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
  RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"setLocation failed : %@", [cb.error localizedDescription]);
    return NO;
  }
  return YES;
}

- (BOOL) setPriority:(NSInteger)priority forIDs:(NSDictionary *)ids {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return NO;

	NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"priority", nil];
	NSArray *vals = [NSArray arrayWithObjects:
    [ids objectForKey:@"list_id"],
    [ids objectForKey:@"task_series_id"],
    [ids objectForKey:@"task_id"],
    timeline,
    [NSString stringWithFormat:@"%d", priority],
    nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

	NSData *response = [api call:@"rtm.tasks.setPriority" withArgs:args];
  if (! response) return NO;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
  RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"setPriority failed : %@", [cb.error localizedDescription]);
    return NO;
  }
  return YES;
}

- (BOOL) setEstimate:(NSString *)estimate forIDs:(NSDictionary *)ids {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return NO;

	NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", @"estimate", nil];
	NSArray *vals = [NSArray arrayWithObjects:
    [ids objectForKey:@"list_id"],
    [ids objectForKey:@"task_series_id"],
    [ids objectForKey:@"task_id"],
    timeline,
    estimate,
    nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

	NSData *response = [api call:@"rtm.tasks.setEstimate" withArgs:args];
  if (! response) return NO;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
  RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"setEstimate failed : %@", [cb.error localizedDescription]);
    return NO;
  }
  return YES;
}

- (BOOL) complete:(NSDictionary *)ids {
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return NO;

	NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id",  @"timeline", nil];
	NSArray *vals = [NSArray arrayWithObjects:
    [ids objectForKey:@"list_id"],
    [ids objectForKey:@"task_series_id"],
    [ids objectForKey:@"task_id"],
    timeline,
    nil];
	NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

	NSData *response = [api call:@"rtm.tasks.complete" withArgs:args];
  if (! response) return NO;

  NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
  RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
  [parser setDelegate:cb];
  [parser parse];
  if (! cb.succeeded) {
    NSLog(@"complete failed : %@", [cb.error localizedDescription]);
    return NO;
  }
  return YES;
}

@end
