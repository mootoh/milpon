//
//  RTMList.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMStorable.h"

@interface RTMList : RTMStorable
{
   NSString *name;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly) NSArray *tasks;

- (id) initByParams:(NSDictionary *)params;
- (NSInteger) taskCount;

@end
// vim:set ft=objc:
