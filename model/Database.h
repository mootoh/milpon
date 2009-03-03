//
//  Database.h
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@interface Database : NSObject

- (void) select:(NSDictionary *)dict from:(NSString *)table;
+ (Database *) sharedDatabase;

@end
