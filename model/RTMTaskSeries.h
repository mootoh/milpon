//
//  RTMTaskSeries.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@interface RTMTaskSeries : NSObject {
  NSInteger     iD;
  NSString     *created;
  NSString     *modified;
	NSString     *name;
	NSString     *source;
	NSString     *url;
	NSInteger     location_id;
  NSInteger     list_id;
  NSMutableSet *participants;
  NSMutableSet *notes;
  NSMutableSet *tags;
  NSMutableSet *tasks;
}

@property (nonatomic) NSInteger iD;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *modified;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSString *url;
@property (nonatomic) NSInteger location_id;
@property (nonatomic) NSInteger list_id;
@property (nonatomic, retain) NSMutableSet *participants;
@property (nonatomic, retain) NSMutableSet *notes;
@property (nonatomic, retain) NSMutableSet *tags;
@property (nonatomic, retain) NSMutableSet *tasks;

- (id) init:(NSInteger)i created:(NSString *)c modified:(NSString *)m name:(NSString *)n source:(NSString *)s url:(NSString *)u location:(NSInteger )l list_id:(NSInteger) li;
- (id) initByID:(NSInteger) iid;

+ (NSArray *) allTaskSerieses;
+ (NSArray *) taskSeriesesIn:(NSInteger)list_id;
+ (void) erase;
- (void) save;

@end
