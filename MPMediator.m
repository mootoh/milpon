//
//  MPMediator.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPMediator.h"

@implementation MPMediator

- (id) initWithFetchedResultsController:(NSFetchedResultsController *) frc
{
   if (self = [super init]) {
      fetchedResultsController = [frc retain];
   }
   return self;
}

- (void) dealloc
{
   [fetchedResultsController release];
   [super dealloc];
}

- (void) sync:(RTMAPI *)api
{
   NSAssert(NO, @"not reach here");
}

#pragma mark -
- (NSNumber *) integerNumberFromString:(NSString *)string
{
   return [NSNumber numberWithInteger:[string integerValue]];
}

- (NSNumber *) boolNumberFromString:(NSString *)string
{
   return [NSNumber numberWithBool:[string boolValue]];
}

@end