
//
//  RTMPendingTask.h
//  Milpon
//
//  Created by mootoh on 10/15/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

@class RTMDatabase;

@interface RTMPendingTask : RTMStorable {
   NSString *name;
   NSString *due;
   NSInteger location_id;
   NSInteger list_id;
   NSInteger priority;
   NSString *estimate;
}

@property (nonatomic) NSInteger iD_;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *due;
@property (nonatomic) NSInteger location_id;
@property (nonatomic) NSInteger list_id;
@property (nonatomic) NSInteger priority;
@property (nonatomic, retain) NSString *estimate;

- (id) initWithDB:(RTMDatabase *)ddb withParams:(NSDictionary *)params;

+ (void) createTask:(NSDictionary *)params inDB:(RTMDatabase *)db;
+ (NSArray *) allTasks:(RTMDatabase *)db;

@end
// set vim:ft=objc
