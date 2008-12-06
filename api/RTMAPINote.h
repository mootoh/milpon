//
//  RTMAPINote.h
//  Milpon
//
//  Created by mootoh on 12/06/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@interface RTMAPINote : NSObject {
  enum {
    // METHOD     ARGS
    NOTES_ADD,    //          note_title, note_text, list_id, taskseries_id, task_id
    NOTES_DELETE, // note_id
    NOTES_EDIT    // note_id, note_title, note_text
  } method;
}

- (BOOL) add:(NSString *)text forIDs:(NSDictionary *)ids;
- (BOOL) delete:(NSNumber *)note_id;
- (BOOL) edit:(NSNumber *)note_id withTitle:(NSString *)title withText:(NSString *)text;

@end
// vim:set ft=objc:
