//
//  MockTagProvider.h
//  Milpon
//
//  Created by mootoh on 1/28/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagProvider.h"

@interface MockTagProvider : NSObject <TagProvider>
{
   NSArray *fixed_tags;
}

- (NSArray *)tags;

@end

