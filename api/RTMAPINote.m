//
//  RTMAPINote.m
//  Milpon
//
//  Created by mootoh on 12/06/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPINote.h"
#import "RTMAPI.h"
#import "RTMAPIXMLParserCallback.h"
#import "logger.h"

@implementation RTMAPINote

- (BOOL) add:(NSString *)text forIDs:(NSDictionary *)ids
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   NSString *timeline = [api createTimeline];
   if (! timeline) return NO;

   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"note_title", @"note_text", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:[ids objectForKey:@"list_id"], [ids objectForKey:@"taskseries_id"], [ids objectForKey:@"task_id"], @"", text, timeline, nil];
   NSDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];

   NSData *response = [api call:@"rtm.tasks.notes.add" withArgs:args];
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

- (BOOL) delete:(NSNumber *)note_id
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   NSString *timeline = [api createTimeline];
   if (! timeline) return NO;

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

- (BOOL) edit:(NSNumber *)note_id withTitle:(NSString *)title withText:(NSString *)text
{
   // TODO: implement this
   return NO;
}

@end
