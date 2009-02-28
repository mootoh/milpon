//
//  MockListProvider.h
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "ListProvider.h"

@interface ListProvider (Mock)

+ (ListProvider *) sharedListProvider;

@end

@interface MockListProvider : ListProvider
{
   NSMutableArray *lists_;
}

@end
