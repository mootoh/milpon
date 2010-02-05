//
//  RTMAPINote.m
//  Milpon
//
//  Created by mootoh on 12/06/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPINote.h"
#import "RTMAPI.h"
#import "RTMNote.h"
#import "RTMAPIXMLParserCallback.h"
#import "logger.h"

@interface NoteAddCallback : RTMAPIXMLParserCallback
{
   NSInteger note_id;
}
@property (nonatomic,readonly) NSInteger note_id;
@end // NoteAddCallback

@implementation NoteAddCallback
@synthesize note_id;
- (id) init
{
   if (self = [super init]) {
      note_id = -1;
   }
   return self;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
   
   if ([elementName isEqualToString:@"note"])
      note_id = [[attributeDict valueForKey:@"id"] integerValue];
}
@end


@implementation RTMAPINote

- (NSInteger) add:(RTMNote *)note forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"note_title", @"note_text", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:[ids objectForKey:@"list_id"], [ids objectForKey:@"taskseries_id"], [ids objectForKey:@"task_id"], note.title ? note.title : @"", note.text, timeLine, nil];
   NSDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.notes.add" withArgs:args];
   if (! response) return -1;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   NoteAddCallback *cb = [[[NoteAddCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"add failed : %@", [cb.error localizedDescription]);
      return -1;
   }
   return cb.note_id;
}

- (BOOL) delete:(NSNumber *)note_id withTimeline:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];

   NSString *str_note_id = [NSString stringWithFormat:@"%d", [note_id integerValue]];
   NSDictionary *args = [NSDictionary dictionaryWithObject:str_note_id forKey:@"note_id"];

   NSData *response = [api call:@"rtm.tasks.notes.delete" withArgs:args];
   if (! response) return NO;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"delete failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

- (BOOL) edit:(NSDictionary *)ids withTitle:(NSString *)title withText:(NSString *)text withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"note_title", @"note_text", @"note_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:[ids objectForKey:@"list_id"], [ids objectForKey:@"taskseries_id"], [ids objectForKey:@"task_id"], title ? title : @"", text, [ids objectForKey:@"note_id"], timeLine, nil];
   NSDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   
   NSData *response = [api call:@"rtm.tasks.notes.edit" withArgs:args];
   if (! response) return NO;
   
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   RTMAPIXMLParserCallback *cb = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   [parser parse];
   if (! cb.succeeded) {
      LOG(@"add failed : %@", [cb.error localizedDescription]);
      return NO;
   }
   return YES;
}

@end
