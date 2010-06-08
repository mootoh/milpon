//
//  MPListViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MPListViewController : UITableViewController
{
   NSArray *lists;
   NSFetchedResultsController *fetchedResultsController;
   NSManagedObjectContext     *managedObjectContext;
}

@property (nonatomic, retain) NSArray *lists;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext     *managedObjectContext;

@end