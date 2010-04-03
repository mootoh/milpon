//
//  InfoViewController.m
//  Milpon
//
//  Created by Motohiro Takayama on 3/29/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "InfoViewController.h"
#import "AppDelegate.h"
#import "DCSatisfactionRemoteViewController.h"

@interface InfoViewController (Private)
- (void) sendFeedbackMail;
@end

@implementation InfoViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
   self.navigationItem.rightBarButtonItem = backButton;
   [backButton release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
   
   switch (indexPath.row) {
      case 0:
         cell.textLabel.text = @"Send Feedback by Mail";
         break;
      case 1:
         cell.textLabel.text =@"User Support Forum";
         break;
      case 2:
         cell.textLabel.text = @"Clear Cache";
      default:
         break;
   }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   switch (indexPath.row) {
      case 0:
         [self sendFeedbackMail];
         break;
      case 1: {
         AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
         [appDelegate launchSatisfactionRemoteComponent:self.navigationController];
         break;
      }
      case 2: {
         AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
         [appDelegate replaceAll];
      }
      default:
         break;
   }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [super dealloc];
}

- (void) dismiss
{
   [self dismissModalViewControllerAnimated:YES];
}

@end

@implementation InfoViewController (Private)

- (void) sendFeedbackMail
{
   // TODO: use in-app mail or GetSatisfaction library.
   NSString *subject = [NSString stringWithFormat:@"subject=Milpon Feedback"];
   NSString *mailto = [NSString stringWithFormat:@"mailto:mootoh@gmail.com?%@", [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   NSURL *url = [NSURL URLWithString:mailto];
   [[UIApplication sharedApplication] openURL:url];
   return;
}

@end