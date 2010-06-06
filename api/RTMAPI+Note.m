//
//  RTMAPINote.m
//  Milpon
//
//  Created by mootoh on 12/06/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"
#import "RTMAPI+Note.h"
#import "RTMAPIParserDelegate.h"
#import "logger.h"

@interface NoteAddCallback : RTMAPIParserDelegate
{
   NSMutableDictionary *note;
   NSString            *text;
}
@end

@implementation NoteAddCallback

- (id) init
{
   if (self = [super init]) {
      note = nil;
      text = @"";
   }
   return self;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;
   
   if ([elementName isEqualToString:@"note"])
      note = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   text = [text stringByAppendingString:chars];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"note"])
      [note setObject:text forKey:@"text"];
}
      
- (id) result
{
   return note;
}

@end

@implementation RTMAPI (Note)

- (NSDictionary *) addNote:(NSString *)title text:(NSString *)text timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id
{
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"note_title", @"note_text", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, title, text, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   return (NSDictionary *)[self call:@"rtm.tasks.notes.add" args:args withDelegate:[[[NoteAddCallback alloc] init] autorelease]];
}

- (void) deleteNote:(NSString *)note_id timeline:(NSString *)timeline
{
   NSArray *keys = [NSArray arrayWithObjects:@"note_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:note_id, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [self call:@"rtm.tasks.notes.delete" args:args withDelegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

#if 0
- (BOOL) edit:(NSDictionary *)ids withTitle:(NSString *)title withText:(NSString *)text withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"note_title", @"note_text", @"note_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:[ids objectForKey:@"list_id"], [ids objectForKey:@"taskseries_id"], [ids objectForKey:@"task_id"], title ? title : @"", text, [ids objectForKey:@"note_id"], timeLine, nil];
   NSDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   
   NSData *response = [api call:@"rtm.tasks.notes.edit" withArgs:args];
   if (! response) return NO;
   
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIParserDelegate *cb = [[[RTMAPIParserDelegate alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"add failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}
#endif // 0
@end