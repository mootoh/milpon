//
//  TagListViewController.h
//  Milpon
//
//  Created by mootoh on 3/11/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "ReloadableTableViewController.h"

@class RTMTag;

@interface TagListViewController : UITableViewController <ReloadableTableViewControllerProtocol>
{
   RTMTag *tag;
   NSArray *tasks;
}

- (id)initWithStyle:(UITableViewStyle)style tag:(RTMTag *)tag;

@property (nonatomic, retain) RTMTag *tag;
@property (nonatomic, retain) NSArray *tasks;

- (IBAction) addTaskInTag;

@end
