/*
 *  NoteProvider.h
 *  Milpon
 *
 *  Created by mootoh on 1/26/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@class RTMNote;
@class RTMTask;

@interface NoteProvider : NSObject

- (NSArray *) notesInTask:(NSInteger) task_id;
- (NSArray *) modifiedNotes;
- (void) createNoteAtOnline:(NSString *)text title:(NSString *)title task_id:(NSInteger)task_id note_id:(NSInteger)note_id;
- (NSNumber *) createAtOffline:(NSString *)note inTask:(NSInteger) task_id;
- (void) update:(RTMNote *)note text:(NSString *)text;
- (void) remove:(NSInteger) note_id;
- (void) removeForTask:(RTMTask *) task_id;

+ (NoteProvider *) sharedNoteProvider;

@end // NoteProvider
