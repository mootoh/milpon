//
//  AuthWebViewController.m
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "AuthWebViewController.h"

@implementation AuthWebViewController

@synthesize url;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
// Custom initialization
}
return self;
}
*/

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView
{
   [super loadView];

   self.title = @"Authorize";

   CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
   UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height-44)];
   webView.scalesPageToFit = YES;

   NSURLRequest *req = [NSURLRequest requestWithURL:url];
   [webView loadRequest:req];
   [self.view addSubview:webView];
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
[super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
   [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
