//
//  RTMList.m
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "Collection.h"
#import "RTMList.h"
#import "RTMTask.h"
#import "ListProvider.h"
#import "TaskProvider.h"

@implementation RTMList

@synthesize name, filter;

- (id) initWithID:(NSNumber *)idd forName:(NSString *)nm
{
   if (self = [super init]) {
      self.name = nm;
   }
   return self;
}

- (id) initWithID:(NSNumber *)idd forName:(NSString *)nm withFilter:(NSString *)filt
{
   if ([self initWithID:idd forName:nm]) {
      self.filter = filt;
   }
   return self;
}

- (void) dealloc
{
   if (iD) [iD release];
   if (name) [name release];
   if (filter) [filter release];
   [super dealloc];
}

- (NSArray *) tasks
{
   return [[TaskProvider sharedTaskProvider] tasksInList:self];
}

- (BOOL) isSmart
{
   return filter != nil;
}

- (NSInteger) taskCount
{
   return [[ListProvider sharedListProvider] taskCountInList:self];
}

+ (NSString *) table_name
{
   return @"list";
}

@end // RTMList