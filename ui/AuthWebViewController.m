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

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
      self.title = NSLocalizedString(@"AuthWebviewTitle", @"auth web view title");
      
      CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
      webView_ = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height-44)];
      webView_.delegate = self;
      webView_.scalesPageToFit = YES;
      state = 0;
   }
   return self;
}

- (void) startLoading
{
   NSURLRequest *req = [NSURLRequest requestWithURL:url];
   [webView_ loadRequest:req];
}

- (void)loadView
{
   [super loadView];
   [self.view addSubview:webView_];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}

- (void)dealloc
{
   [webView_ release];
   [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
   [super viewDidDisappear:animated];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"didDismissWebView" object:nil];
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
   NSLog(@"authorizingPhase = %d", authorizeingPhase);
   if (authorizeingPhase) {
      if (state == 0) {
         state++;
         [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms['loginform']; form.submit();"];
         return;
      } else {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"didFailInAuth" object:nil];
         return;
      }         
   }

   // authorize it
   NSString *authorize_yes = [webView stringByEvaluatingJavaScriptFromString:@"var authorize_yes = document.getElementById('authorize_yes'); authorize_yes ? 'yes' : '';"];
   if ([authorize_yes isEqualToString:@""]) {
      if (state == 0) {
         return;
      }
   } else if (state == 1) {
      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms[0]; form ? 'form exist' : 'form not';"];

      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms.length; form;"];      

      NSLog(@"form count= %@", result);

//      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms[0]; form.submit();"];
//      NSLog(@"submit result = %@", result);
      [self.view addSubview:webView_];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"presentAuthWebView" object:nil];

      state++;
      return;
   }
   
   result = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('pageheader').children[0].children[0].innerHTML"];
   NSLog(@"pageheader = %@", result);
   if ([result isEqualToString:@"Application successfully authorized"]) {
      NSLog(@"finished");
      state++;
      [[NSNotificationCenter defaultCenter] postNotificationName:@"didSucceedInAuth" object:nil];
   }
}  

- (void) stop
{
   [webView_ stopLoading];
}

@end