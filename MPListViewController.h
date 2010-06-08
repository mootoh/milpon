//
//  MPListViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPListViewController : UITableViewController
{
   NSArray *lists;
}

@property (nonatomic, retain) NSArray *lists;

@end