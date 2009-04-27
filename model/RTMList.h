//
//  RTMList.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "Collection.h"

@interface RTMList : RTMObject <Collection>
{
   NSString *name;
   NSString *filter;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *filter;
@property (nonatomic, readonly) NSArray *tasks;

- (id) initWithID:(NSNumber *)id_ forName:(NSString *)nm;
- (id) initWithID:(NSNumber *)id_ forName:(NSString *)nm withFilter:(NSString *)filt;
- (BOOL) isSmart;

@end
// vim:set ft=objc:
