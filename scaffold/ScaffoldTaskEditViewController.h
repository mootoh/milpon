//
//  ScaffoldTaskEditViewController.h
//  Milpon
//
//  Created by mootoh on 3/8/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class RTMTask;

@interface ScaffoldTaskEditViewController : UITableViewController
{
   IBOutlet RTMTask *task;
}

@property (nonatomic, retain) RTMTask *task;

@end
