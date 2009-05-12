//
//  NoteProvider.m
//  Milpon
//
//  Created by mootoh on 2/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "NoteProvider.h"

@implementation NoteProvider

- (NSArray *) notesInTask:(NSInteger) task_id
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (NSNumber *) createAtOffline:(NSString *)note inTask:(NSInteger) task_id
{
   NSAssert(NO, @"not reach here");
   return nil;
}

- (void) update:(RTMNote *)note text:(NSString *)text
{
   NSAssert(NO, @"not reach here");
}

+ (NoteProvider *) sharedNoteProvider
{
   NSAssert(NO, @"not reach here");
   return nil;
}
   
@end
