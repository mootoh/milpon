//
//  MockListProvider.m
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "MockListProvider.h"

@implementation MockListProvider

- (id) init
{
   if (self = [super init]) {
      lists_ = [[NSMutableArray arrayWithObjects:@"Inbox", @"Action", @"Project", nil] retain];
   }
   return self;
}

- (void) dealloc
{
   [lists_ release];
   [super dealloc];
}

- (NSArray *) lists
{
   return lists_;
}

- (void) add:(NSString *)elm
{
   [lists_ addObject:elm];
}

- (NSArray *) tasksInList:(RTMList *)list
{
   return [NSArray arrayWithObjects:@"one", @"two", @"three", nil];
}

@end // MockListProvider

@implementation ListProvider (Mock)

static MockListProvider *s_mock_list_provider = nil;

+ (ListProvider *) sharedListProvider
{
   if (nil == s_mock_list_provider) {
      s_mock_list_provider = [[MockListProvider alloc] init];
   }
   return s_mock_list_provider;   
}

@end // ListProvider (Mock)
