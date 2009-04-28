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
{
/*
   NSString *name;
   NSString *filter;
*/
}

@property (nonatomic, assign) NSString *name;
//@property (nonatomic, assign) NSString *filter;
//@property (nonatomic, readonly) NSArray *tasks;

/*
- (id) initWithID:(NSNumber *)id_ forName:(NSString *)nm;
- (id) initWithID:(NSNumber *)id_ forName:(NSString *)nm withFilter:(NSString *)filt;
- (BOOL) isSmart;
*/

enum list_edit_bits_t {
   EB_LIST_NAME         = 1 << 1,
   EB_TASK_FILTER       = 1 << 2,
};

@end