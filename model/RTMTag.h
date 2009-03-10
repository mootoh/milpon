//
//  RTMTag.h
//  Milpon
//
//  Created by mootoh on 3/10/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@interface RTMTag : NSObject <NSCopying>
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
