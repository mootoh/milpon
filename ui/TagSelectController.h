//
//  TagSelectController.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class AddTaskViewController;
@class TagProvider;

@interface TagSelectController : UITableViewController {
   TagProvider *tag_provider;
   AddTaskViewController *parent;
   NSMutableSet *selected_tags;
   NSMutableDictionary *selected_flags;
   NSArray *all_tags;
}

- (void) setTags:(NSMutableSet *) tags;

@property (nonatomic, retain) AddTaskViewController *parent;
@property (nonatomic, retain) NSMutableSet *selected_tags;
@property (nonatomic, retain) NSArray *all_tags;

@end