//
//  MenuViewController.h
//  Milpon
//
//  Created by mootoh on 10/4/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController
{
   enum {
      MENU_OVERVIEW,
      MENU_LIST,
/*      
      MENU_TAG,
      MENU_LOCATION,
 */
      MENU_COUNT
   } menu_type;
   
   NSArray *items;
   UIToolbar *bottomBar;
}

@property (nonatomic,retain) UIToolbar *bottomBar;
@end
