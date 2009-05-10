//
//  TagSelectController.h
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@class AddTaskViewController;
@class TagProvider;
@protocol HavingTag;

@interface TagSelectController : UITableViewController {
   TagProvider *tag_provider;
   UIViewController <HavingTag> *parent;
   NSMutableSet *selected_tags;
   NSMutableDictionary *selected_flags;
   NSArray *all_tags;
}

- (void) setTags:(NSMutableSet *) tags;

@property (nonatomic, retain) UIViewController <HavingTag> *parent;
@property (nonatomic, retain) NSMutableSet *selected_tags;
@property (nonatomic, retain) NSArray *all_tags;

@end