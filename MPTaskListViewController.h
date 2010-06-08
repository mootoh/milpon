//
//  MPTaskListViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MPTaskListViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
   NSFetchedResultsController *fetchedResultsController;
   NSManagedObjectContext     *managedObjectContext;
   NSNumber *list;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext     *managedObjectContext;
@property (nonatomic, retain) NSNumber *list;

@end