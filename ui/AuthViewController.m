#import "AuthViewController.h"
#import "RTMAPI.h"
#import "RTMAPI+Auth.h"
#import "AppDelegate.h"
#import "ReloadableTableViewController.h"
#import "MPLogger.h"
#import "RTMSynchronizer.h"

@implementation AuthViewController

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
   if (self = [super initWithNibName:nibName bundle:bundle]) {
      state      = STATE_INITIAL;
      syncer     = nil;
      frob       = nil;
      self.title = NSLocalizedString(@"Setup", "setup screen");
   }
   return self;
}

- (void) dealloc
{
   [frob release];
   [syncer release];
   [super dealloc];
}

- (void) reset
{
   usernameField.enabled = YES;
   passwordField.enabled = YES;
   proceedButton.enabled = YES;
   webView.hidden        = YES;
   
   [authActivity stopAnimating];
   [usernameField becomeFirstResponder];
}

- (void) setInitialInstruction
{
   instructionLabel.text = @"Press OK button in the next screen."; // TODO: localize it
}

- (void) viewDidLoad
{
   [super viewDidLoad];
   [self reset];
   [self performSelector:@selector(setInitialInstruction) withObject:nil afterDelay:2.0];
}

- (IBAction) proceedToAuthorization
{
   NSAssert(state == STATE_INITIAL || state == STATE_WRONG_PASSWORD, @"check state");
   instructionLabel.text = @"Authorizing...";
   
   [usernameField resignFirstResponder];
   usernameField.enabled = NO;
   [passwordField resignFirstResponder];
   passwordField.enabled = NO;
   proceedButton.enabled = NO;
   
   [authActivity startAnimating];

   // get Frob
   AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
   @try {
      frob = [[appDelegate.api getFrob] retain];
   }
   @catch (NSException *e) {
      LOG(@"exception : %@ : %@", e.name, e.reason);
      NSError *error = [e.userInfo objectForKey:@"error"];
      if (error.code == RTM_ERROR_SERVICE_DOWN) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RTM is down" message:@"RTM is currently unavailable. Try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alertView show];
         return;
      }
      [self failedInAuthorization];
      return;
   }
   
   NSString *urlString = [appDelegate.api authURL:frob forPermission:@"delete"];
   NSURL      *authURL = [NSURL URLWithString:urlString];
   NSURLRequest   *req = [NSURLRequest requestWithURL:authURL];
   webView.hidden      = YES;
   [webView loadRequest:req];
   
   state = STATE_SUBMITTED;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   [self reset];
}

- (void) failedInAuthorization
{
   NSAssert(state == STATE_INITIAL || state == STATE_SUBMITTED || state == STATE_USERINFO_ENTERED|| state == STATE_WRONG_PASSWORD, @"check state");
   [webView stopLoading];
   state = STATE_WRONG_PASSWORD;
   instructionLabel.text = @"Wrong Username / Password.";
   [self performSelector:@selector(reset) withObject:nil afterDelay:1.0f];
}

- (void) didSucceedInAuth
{
   instructionLabel.text = @"Loading Tasks...";
   [webView stopLoading];
   webView.hidden = YES;

   [UIView beginAnimations:@"didSucceedInAuth" context:nil];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(didSucceedInAuthAnimationStop:finished:context:)];
   [UIView setAnimationDuration:0.5f];
   {   
      usernameField.alpha     = 0.0f;
      passwordField.alpha     = 0.0f;
      proceedButton.alpha     = 0.0f;
      instructionLabel.center = [UIApplication sharedApplication].keyWindow.center;
   }
   [UIView commitAnimations];
}

- (void)didSucceedInAuthAnimationStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   usernameField.hidden = YES;
   passwordField.hidden = YES;
   proceedButton.hidden = YES;
   
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   [self getToken:app.api];
   syncer = [[RTMSynchronizer alloc] initWithAPI:app.api];
   syncer.delegate = self;
   [syncer replaceAll];
}

- (IBAction) getToken:(RTMAPI *)api
{
   [authActivity startAnimating];

   NSString *token = [api getToken:frob];

   [authActivity stopAnimating];

   if (! token) {
      [self failedInAuthorization];
      return;
   }
   
   api.token = token;
}

- (void) backToRootMenu
{
   [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRootMenu" object:nil];
}

#pragma mark -
#pragma mark RTMSynchronizerDelegate

- (void) didUpdate
{
}

- (void) didReplaceAll
{
   LOG(@"didReplaceAll");
   instructionLabel.text = @"Done!";
   [self performSelector:@selector(backToRootMenu) withObject:nil afterDelay:1.0f];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)wv
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   
   if (state == STATE_WRONG_PASSWORD) return;
   
   // authorizing case
   BOOL authorizeingPhase = NO;
   
   NSString *result = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var username = document.getElementById('username'); username.value = '%@';", usernameField.text]];
   authorizeingPhase = ![result isEqualToString:@""];
   result = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var password = document.getElementById('password'); password.value='%@';", passwordField.text]];
   authorizeingPhase = authorizeingPhase && ![result isEqualToString:@""];
   //NSLog(@"authorizingPhase = %d", authorizeingPhase);
   if (authorizeingPhase) {
      if (state == STATE_SUBMITTED) {
         [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms['loginform']; form.submit();"];
         state = STATE_USERINFO_ENTERED;
         return;
      } else {
         [self failedInAuthorization];
         return;
      }         
   }
   
   // authorize it
   NSString *authorize_yes = [webView stringByEvaluatingJavaScriptFromString:@"var authorize_yes = document.getElementById('authorize_yes'); authorize_yes ? 'yes' : '';"];
   if (! [authorize_yes isEqualToString:@""] && state == STATE_USERINFO_ENTERED) {
      [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms[0]; form ? 'form exist' : 'form not';"];
//      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms.length; form;"];      
//      
//      NSLog(@"form count= %@", result);
      
      //      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms[0]; form.submit();"];
      //      NSLog(@"submit result = %@", result);
      webView.hidden = NO;
      //[[NSNotificationCenter defaultCenter] postNotificationName:@"presentAuthWebView" object:nil];
      
      state = STATE_SHOW_WEBVIEW;
      return;
   }
   
   result = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('pageheader').children[0].children[0].innerHTML"];
   //NSLog(@"pageheader = %@", result);
   if ([result isEqualToString:@"Application successfully authorized"]) {
      NSAssert(state == STATE_SHOW_WEBVIEW || state == STATE_USERINFO_ENTERED, @"check state");
      state = STATE_DONE;
      [self didSucceedInAuth];
   }
}  

@end