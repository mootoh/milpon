//
//  TaskListViewController.h
//  Milpon
//
//  Created by mootoh on 9/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class RTMList;
@protocol Collection;

@interface TaskListViewController : UITableViewController
{
   //RTMList *list;
   NSArray *tasks;
   NSObject <Collection> *collection;
   BOOL showCompleted;
}

//@property (nonatomic, retain) RTMList *list;
@property (nonatomic, retain) NSArray *tasks;
@property (nonatomic, retain) NSObject <Collection> *collection;

- (id)initWithStyle:(UITableViewStyle)style withCollection:(NSObject <Collection> *)cols;
- (IBAction) addTaskInList;
- (IBAction) addTaskInTag;

@end
