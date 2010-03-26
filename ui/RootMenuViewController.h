//
//  RootMenuViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 3/26/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressView;

@interface RootMenuViewController : UITableViewController
{
   UIBarButtonItem                 *refreshButton;
   ProgressView                    *pv;
}

- (IBAction) fetchAll;
- (IBAction) refresh;
- (IBAction) showDialog;
- (void) showFetchAllModal;

@end