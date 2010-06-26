//
//  MPListViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/8/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MPListMediator, MPTaskMediator;

@interface MPListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
   NSFetchedResultsController *fetchedResultsController;
   NSManagedObjectContext     *managedObjectContext;
   MPListMediator             *listMediator;
   MPTaskMediator             *taskMediator;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext     *managedObjectContext;

@end