//
//  RTMNote.m
//  Milpon
//
//  Created by mootoh on 10/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMNote.h"

@implementation RTMNote

DEFINE_ATTRIBUTE(title, Title, NSString*, EB_NOTE_MODIFIED);
DEFINE_ATTRIBUTE(text, Text, NSString*, EB_NOTE_MODIFIED);
DEFINE_ATTRIBUTE_RO(task_id, NSNumber *);


+ (NSString *) table_name
{
   return @"note";
}

@end