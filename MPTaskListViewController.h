//
//  MPTaskListViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MPTaskListViewController : UITableViewController {
   NSArray  *taskserieses;
   NSString *list;
}

@property (nonatomic, retain) NSArray  *taskserieses;
@property (nonatomic, retain) NSString *list;

@end