//
//  RootMenuViewController.h
//  Milpon
//
//  Created by mootoh on 4/12/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class ProgressView;

@interface RootMenuViewController : UITableViewController
{
   UIBarButtonItem                 *refreshButton;
   ProgressView                    *pv;
}

- (IBAction) refresh;
- (IBAction) showDialog;

@end