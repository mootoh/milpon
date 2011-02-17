//
//  RTMAPINote.h
//  Milpon
//
//  Created by mootoh on 12/06/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//
#import "RTMAPI.h"

@interface RTMAPI (Note)

- (NSDictionary *) addNote:(NSString *)title text:(NSString *)text timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id;
- (void) deleteNote:(NSString *)note_id timeline:(NSString *)timeline;
- (NSDictionary *) editNote:(NSString *)note_id title:(NSString *)title text:(NSString *)text timeline:(NSString *)timeline;

@end