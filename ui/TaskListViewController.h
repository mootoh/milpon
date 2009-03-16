//
//  TaskListViewController.h
//  Milpon
//
//  Created by mootoh on 9/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ReloadableTableViewController.h"

@class RTMList;

@interface TaskListViewController : UITableViewController <ReloadableTableViewControllerProtocol>
{
   RTMList *list;
   NSArray *tasks;
}

- (id)initWithStyle:(UITableViewStyle)style withList:(RTMList *)lst;

@property (nonatomic, retain) RTMList *list;
@property (nonatomic, retain) NSArray *tasks;

- (IBAction) addTaskInList;

@end
