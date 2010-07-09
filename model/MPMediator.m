//
//  MPMediator.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPMediator.h"
#import "MPLogger.h"

@implementation MPMediator
@synthesize managedObjectContext;

- (id) initWithManagedObjectContext:(NSManagedObjectContext *) moc
{
   if (self = [super init]) {
      self.managedObjectContext = moc;
   }
   return self;
}

- (void) dealloc
{
   [managedObjectContext release];
   [super dealloc];
}

- (void) sync:(RTMAPI *)api
{
   NSAssert(NO, @"not reach here");
}

@end

#pragma mark -

NSNumber *integerNumberFromString(NSString *string)
{
   return [NSNumber numberWithInteger:[string integerValue]];
}

NSNumber *boolNumberFromString(NSString *string)
{
   return [NSNumber numberWithBool:[string boolValue]];
}
