//
//  TrialListProvider.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListProvider.h"

@interface TrialListProvider : NSObject <ListProvider>
{
   NSArray *fixed_lists;
}

- (NSArray *) lists;

@end
