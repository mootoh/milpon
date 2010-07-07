//
//  MPTaskViewController.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/10/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MPTaskViewController : UITableViewController
{
   NSFetchedResultsController *fetchedResultsController;
   NSManagedObjectContext     *managedObjectContext;
   NSManagedObject            *taskObject;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext     *managedObjectContext;
@property (nonatomic, retain) NSManagedObject            *taskObject;

@end