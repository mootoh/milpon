//
//  TaskCollectionViewController.h
//  Milpon
//
//  Created by mootoh on 4/14/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@protocol TaskCollection;

@interface TaskCollectionViewController : UITableViewController
{
   NSObject <TaskCollection> *collector;
   NSArray *collection;
}

@property (nonatomic, retain) NSObject <TaskCollection> *collector;

@end
