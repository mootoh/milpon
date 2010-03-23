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
@synthesize username, password;

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

   self.title = NSLocalizedString(@"AuthWebviewTitle", @"auth web view title");

   CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
   webView_ = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height-44)];
   webView_.delegate = self;
   webView_.scalesPageToFit = YES;

   NSURLRequest *req = [NSURLRequest requestWithURL:url];
   [webView_ loadRequest:req];
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
   [super viewDidLoad];
   state = 0;
}

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
   [webView_ release];
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

   // authorizing case
   BOOL authorizeingPhase = NO;

   NSString *result = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var username = document.getElementById('username'); username.value = '%@';", username]];
   authorizeingPhase = ![result isEqualToString:@""];
   result = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var password = document.getElementById('password'); password.value='%@';", password]];
   authorizeingPhase = authorizeingPhase && ![result isEqualToString:@""];
   NSLog(@"au = %d", authorizeingPhase);
   if (authorizeingPhase && state == 0) {
      state++;
      [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms['loginform']; form.submit();"];
      return;
   }

   // authorize it
   NSString *authorize_yes = [webView stringByEvaluatingJavaScriptFromString:@"var authorize_yes = document.getElementById('authorize_yes'); authorize_yes ? 'yes' : '';"];
   NSLog(@"yes = %@", authorize_yes);
   if ([authorize_yes isEqualToString:@""]) {
      NSLog(@"authorization failed");
   } else if (state == 1) {
      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms[0]; form ? 'form exist' : 'form not';"];
      NSLog(@"form result = %@", result);

      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms.length; form;"];
      
      NSLog(@"form count= %@", result);

//      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms[0]; form.submit();"];
//      NSLog(@"submit result = %@", result);
      [self.view addSubview:webView_];

      state++;
      return;
   }
   
   result = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('pageheader').children[0].children[0].innerHTML"];
   NSLog(@"pageheader = %@", result);
   if ([result isEqualToString:@"Application successfully authorized"]) {
      NSLog(@"finished");
      state++;
      [self dismissModalViewControllerAnimated:YES];
   }
}  

@end
