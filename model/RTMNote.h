//
//  RTMNote.h
//  Milpon
//
//  Created by mootoh on 10/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMObject.h"

@interface RTMNote : RTMObject

@property (nonatomic, assign) NSString   *title;
@property (nonatomic, assign) NSString   *text;
@property (nonatomic, readonly) NSNumber *task_id;

enum note_edit_bits_t {
   EB_NOTE_TITLE = 1 << 1,
   EB_NOTE_TEXT  = 1 << 2
};

@end