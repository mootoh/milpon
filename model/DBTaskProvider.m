//
//  DBTaskProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBTaskProvider.h"
#import "RTMTask.h"
#import "LocalCache.h"

@implementation DBTaskProvider

- (id) init
{
   if (self = [super init]) {
      local_cache_ = [LocalCache sharedLocalCache];
      tasks_ = [self tasks];
   }
   return self;
}

- (void) dealloc
{
   [tasks_ release];
   [super dealloc];
}

- (NSArray *) tasks
{
   NSMutableArray *tasks = [NSMutableArray array];
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   NSArray *keys  = [NSArray arrayWithObjects:@"id", @"name", nil];
   NSArray *types = [NSArray arrayWithObjects:[NSNumber class], [NSString class], nil];
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:types forKeys:keys];

   NSArray *list_arr = [local_cache_ select:dict from:@"list"];
   for (NSDictionary *dict in list_arr) {
      RTMTask *lst = [[[RTMTask alloc]
            initWithID:[dict objectForKey:@"id"]
            forName:[dict objectForKey:@"name"]]
         autorelease];
      [tasks addObject:lst];
   }
   [pool release];
   return tasks;
}

- (NSArray *) tasksInTask:(RTMTask *)list
{
   //TaskProvider *task_provider = [TaskProvider sharedTaskProvider];
   return nil;
}

@end

@implementation TaskProvider (DB)

static DBTaskProvider *s_db_list_provider = nil;

+ (TaskProvider *) sharedTaskProvider
{
   if (nil == s_db_list_provider)
      s_db_list_provider = [[DBTaskProvider alloc] init];
   return s_db_list_provider; 
}

@end // TaskProvider (Mock)
