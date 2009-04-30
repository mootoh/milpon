//
//  RTMList.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "Collection.h"
#import "RTMObject.h"

@interface RTMList : RTMObject <Collection>

@property (nonatomic, assign)   NSString *name;
@property (nonatomic, readonly) NSString *filter;
@property (nonatomic, readonly) NSArray  *tasks;

- (BOOL) isSmart;
- (NSInteger) taskCount;

enum list_edit_bits_t {
   EB_LIST_NAME   = 1 << 1
};

@end