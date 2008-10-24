//
//  ConfigViewController.m
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ConfigViewController.h"
#import "RootViewController.h"
#import "MenuViewController.h"

#define VERSION "$Id$"
@implementation ConfigViewController

@synthesize rootViewController;

- (id)initWithStyle:(UITableViewStyle)style {
  if (self = [super initWithStyle:style]) {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(appFrame.size.width/2-32, appFrame.size.height/2, 64, 64);
    activityIndicator.hidesWhenStopped = YES;
  }
  return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
  [super viewDidLoad];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  self.navigationItem.leftBarButtonItem = doneButton;
  [doneButton release];

  [self.view addSubview:activityIndicator];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return CONFIG_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"ConfigViewCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
  }
  // Configure the cell
  switch (indexPath.row) {
    case CONFIG_RELOAD: {
      cell.text = @"fetch all data from RTM site (long wait)";
      cell.font = [UIFont systemFontOfSize:12];

      UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      reloadButton.frame = CGRectMake(240, 8, 72, 32);
      [reloadButton setTitle:@"fetch all" forState:UIControlStateNormal];
      [reloadButton addTarget:self action:@selector(fetchAll) forControlEvents:UIControlEventTouchDown];
      [cell.contentView addSubview:reloadButton];

      break;
    }
    case CONFIG_VERSION:
      cell.text = [NSString stringWithUTF8String:VERSION];
      break;
    default:
      break;
  }
  return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
  [activityIndicator release];
  [super dealloc];
}

- (void) close {
  /*
  UIViewController *nav = self.parentViewController;;
  nav = nav.parentViewController;;
  ConfigViewController *root = (ConfigViewController *)nav.parentViewController;;
  root.bottomBar.hidden = NO;
  */
  [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done {
  [self close];
}

- (void) fetchAll {
  [activityIndicator startAnimating];
  [self.rootViewController fetchAll];
  [activityIndicator stopAnimating];
}

@end
