//
//  MPMediator.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class RTMAPI;

@interface MPMediator : NSObject
{
   NSManagedObjectContext *managedObjectContext;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext *) moc;
- (void) sync:(RTMAPI *) api;

- (NSNumber *) integerNumberFromString:(NSString *)string;
- (NSNumber *) boolNumberFromString:(NSString *)string;

@end