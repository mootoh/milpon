/*
 *  NoteProvider.h
 *  Milpon
 *
 *  Created by mootoh on 1/26/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@class RTMNote;

@interface NoteProvider : NSObject

- (NSArray *) notesInTask:(NSInteger) task_id;
- (void) create:(NSString *)note inTask:(NSInteger) task_id;

+ (NoteProvider *) sharedNoteProvider;

@end // NoteProvider
