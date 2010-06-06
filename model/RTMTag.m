//
//  RTMTag.m
//  Milpon
//
//  Created by mootoh on 3/10/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "Collection.h"
#import "RTMTag.h"
#import "RTMTask.h"
#import "TagProvider.h"
#import "TaskProvider.h"
#import "MPLogger.h"

@implementation RTMTag

@synthesize iD, name;

- (id) initWithID:(NSNumber *)id_ forName:(NSString *)name_
{
   if (self = [super init]) {
      self.iD   = id_;
      self.name = name_;
   }
   return self;
}

- (void) dealloc
{
   if (iD) [iD release];
   if (name) [name release];
   [super dealloc];
}

- (NSArray *) tasks
{
   return [[TaskProvider sharedTaskProvider] tasksInTag:[self.iD integerValue] showCompleted:YES];
}

- (NSInteger) taskCount
{
   return [[TagProvider sharedTagProvider] taskCountInTag:self];
}

+ (NSString *) table_name
{
   return @"tag";
}

- (BOOL) isEqual: (id) anObject
{
   RTMTag *other = (RTMTag *)anObject;
   LOG(@"comparing %@ and %@", self.name, other.name);
   //return other.iD == self.iD && [other.name isEqualToString:self.name];
   LOG(@"other.iD = %d, self.iD = %d, equal? = %d", other.iD, self.iD, other.iD == self.iD);
   LOG(@"other.name = %@, self.name = %@, equal? = %d", other.name, self.name, [other.name isEqualToString:self.name]);
   //return other.iD == self.iD && [other.name isEqualToString:self.name];
   return [other.name isEqualToString:self.name];
}

- (NSComparisonResult) compareByTagName:(RTMTag *)aTag
{
   return [name caseInsensitiveCompare:aTag.name];
}
@end