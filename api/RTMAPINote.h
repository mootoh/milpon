//
//  RTMAPINote.h
//  Milpon
//
//  Created by mootoh on 12/06/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//
@class RTMNote;

@interface RTMAPINote : NSObject {
  enum {
    // METHOD     ARGS
    NOTES_ADD,    //          note_title, note_text, list_id, taskseries_id, task_id
    NOTES_DELETE, // note_id
    NOTES_EDIT    // note_id, note_title, note_text
  } method;
}

- (NSInteger) add:(RTMNote *)note forIDs:(NSDictionary *)ids withTimeLine:(NSString *)timeLine; // if failed, return -1
- (BOOL) delete:(NSNumber *)note_id withTimeline:(NSString *)timeLine;
- (BOOL) edit:(NSDictionary *)ids withTitle:(NSString *)title withText:(NSString *)text withTimeLine:(NSString *)timeLine;

@end
// vim:set ft=objc:
