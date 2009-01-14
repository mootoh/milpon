//
//  MenuViewController.m
//  Milpon
//
//  Created by mootoh on 10/4/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "MenuViewController.h"
#import "ListViewController.h"
#import "HomeViewController.h"
#import "ConfigViewController.h"

@implementation MenuViewController

@synthesize bottomBar, rootViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
      items = [[NSArray arrayWithObjects:@"Overview", @"List", @"Review", nil] retain];
      self.title = @"Milpon";
   }
   return self;
}

- (void) loadView
{
   [super loadView];

   UIBarButtonItem *configButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(config)];
   self.navigationItem.leftBarButtonItem = configButton;
   [configButton release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"RTMTaskCell";

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   }

   cell.text = [items objectAtIndex:indexPath.row];

   // disable some features by now.
   if (indexPath.row > 1)
      cell.textColor = [UIColor grayColor];

   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   switch (indexPath.row) {
      case MENU_OVERVIEW: {
         HomeViewController *ctr = [[HomeViewController alloc] initWithStyle:UITableViewStylePlain];
         [[self navigationController] pushViewController:ctr animated:YES];
         [ctr release];
         break;
      }
      case MENU_LIST: {
         ListViewController *ctr = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
         [[self navigationController] pushViewController:ctr animated:YES];
         [ctr release];
         break;
      }
      default:
         break;
   }
}

/*
   - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
   {

   if (editingStyle == UITableViewCellEditingStyleDelete) {
   }
   if (editingStyle == UITableViewCellEditingStyleInsert) {
   }
   }
   */

/*
   - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
   {
   return YES;
   }
   */

/*
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
   {
   }
   */

/*
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
   {
   return YES;
   }
   */


- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   self.bottomBar.hidden = NO;
}
/*
   - (void)viewDidAppear:(BOOL)animated
   {
   [super viewDidAppear:animated];
   }
   */
- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
}
/*
   - (void)viewDidDisappear:(BOOL)animated
   {
   }
   */
/*
   - (void)didReceiveMemoryWarning
   {
   [super didReceiveMemoryWarning];
   }
   */

- (void)dealloc
{
   [items release];
   [super dealloc];
}

- (IBAction) config
{
   self.bottomBar.hidden = YES;

   ConfigViewController *ctrl = [[ConfigViewController alloc] initWithNibName:nil bundle:nil];
   ctrl.title = @"Info";
   ctrl.rootViewController = self.rootViewController;

   UINavigationController *modalController = [[UINavigationController alloc] initWithRootViewController:ctrl];
   [self.navigationController presentModalViewController:modalController animated:YES];
   [modalController release];
   [ctrl release];
}

@end
