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

   return (NSDictionary *)[self call:@"rtm.tasks.notes.add" args:args delegate:[[[NoteAddCallback alloc] init] autorelease]];
}

- (void) deleteNote:(NSString *)note_id timeline:(NSString *)timeline
{
   NSArray *keys = [NSArray arrayWithObjects:@"note_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:note_id, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [self call:@"rtm.tasks.notes.delete" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (NSDictionary *) editNote:(NSString *)note_id title:(NSString *)title text:(NSString *)text timeline:(NSString *)timeline
{
   NSArray *keys = [NSArray arrayWithObjects:@"note_id", @"note_title", @"note_text", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:note_id, title, text, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   return (NSDictionary *)[self call:@"rtm.tasks.notes.edit" args:args delegate:[[[NoteAddCallback alloc] init] autorelease]];
}

@end