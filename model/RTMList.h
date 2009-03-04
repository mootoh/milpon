//
//  RTMList.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@interface RTMList : NSObject
{
   NSNumber *iD;
   NSString *name;
}

@property (nonatomic, retain) NSNumber *iD;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly) NSArray *tasks;

- (id) initWithID:(NSNumber *)id_ forName:(NSString *)name;

@end
// vim:set ft=objc:
