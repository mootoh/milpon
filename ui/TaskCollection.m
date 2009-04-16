//
//  TaskCollection.m
//  Milpon
//
//  Created by mootoh on 4/14/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TaskCollection.h"
#import "ListProvider.h"
#import "TagProvider.h"

@implementation ListTaskCollection

- (NSArray *) collection
{
   return [[ListProvider sharedListProvider] lists];
}

@end // ListTaskCollection

@implementation TagTaskCollection

- (NSArray *) collection
{
   return [[TagProvider sharedTagProvider] tags];
}

@end // TagTaskCollection