//
//  ListSelectViewController.h
//  Milpon
//
//  Created by mootoh on 10/16/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@class AddTaskViewController;
@protocol HavingList;

@interface ListSelectViewController : UITableViewController
{
   NSArray *lists;
   UIViewController <HavingList> *parent;
}

@property (nonatomic, retain) UIViewController <HavingList> *parent;

@end
