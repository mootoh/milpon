/*
 *  TaskCollection.h
 *  Milpon
 *
 *  Created by mootoh on 4/14/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@protocol TaskCollection

- (NSArray *) collection;

@end

@interface ListTaskCollection : NSObject <TaskCollection>
{

}

@end

@interface TagTaskCollection : NSObject <TaskCollection>
{
   
}

@end
