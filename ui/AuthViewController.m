#import "AuthViewController.h"
#import "RTMAPI.h"
#import "RTMAPIAuth.h"
#import "RTMAuth.h"
#import "AppDelegate.h"
#import "RTMAPI.h"
#import "ReloadableTableViewController.h"
#import "logger.h"

@implementation AuthViewController

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
   if (self = [super initWithNibName:nibName bundle:bundle]) {
      state = STATE_INITIAL;
      self.title = NSLocalizedString(@"Setup", "setup screen");
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (void) reset
{
   usernameField.enabled = YES;
   passwordField.enabled = YES;
   proceedButton.enabled = YES;
   
   [authActivity stopAnimating];
   webView.hidden = YES;
   [usernameField becomeFirstResponder];
}

- (void) setInitialInstruction
{
   instructionLabel.text = @"Press OK button in the next screen.";
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
   RTMAPIAuth *api_auth = [[[RTMAPIAuth alloc] init] autorelease];
   NSString *frob = [api_auth getFrob];
   if (!frob) {
      [self failedInAuthorization];
      return;
   }
   
   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   RTMAuth *auth = app.auth;
   auth.frob = frob;
   
   RTMAPI *api = [[RTMAPI alloc] init];
   NSString *urlString = [api authURL:frob forPermission:@"delete"];
   NSURL *authURL = [NSURL URLWithString:urlString];
   
   LOG(@"authURL = %@", authURL);
   
   NSURLRequest *req = [NSURLRequest requestWithURL:authURL];
   webView.hidden = YES;
   [webView loadRequest:req];
   
   [api release];
   state = STATE_SUBMITTED;
}

- (void) failedInAuthorization
{
   NSLog(@"faildInAuthorization: state=%d", state);
   NSAssert(state == STATE_SUBMITTED || state == STATE_USERINFO_ENTERED, @"check state");
   [webView stopLoading];
   state = STATE_WRONG_PASSWORD;
   
   //   [UIView beginAnimations:@"failedInAuthorization" context:nil];
   //   [UIView setAnimationDelegate:self];
   //   [UIView setAnimationDidStopSelector:@selector(failedInAuthorizationAnimationStop:finished:context:)];
   //   [UIView setAnimationDuration:1.5f];
   //   
   //  webView.alpha = 0.0f;
   //   instructionLabel.text = @"Wrong Username / Password.";   
   //   
   //   [UIView commitAnimations];
   instructionLabel.text = @"Wrong Username / Password.";
   [self performSelector:@selector(reset) withObject:nil afterDelay:1.0f];
}

- (void) didSucceedInAuth
{
   NSLog(@"succeeded in auth");
   instructionLabel.text = @"Loading Tasks...";
   [webView stopLoading];
   webView.hidden = YES;

   [UIView beginAnimations:@"didSucceedInAuth" context:nil];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(didSucceedInAuthAnimationStop:finished:context:)];
   [UIView setAnimationDuration:0.5f];
   {   
      usernameField.alpha = 0.0f;
      passwordField.alpha = 0.0f;
      proceedButton.alpha = 0.0f;
      instructionLabel.center = [UIApplication sharedApplication].keyWindow.center;
   }
   [UIView commitAnimations];
}

- (void)didSucceedInAuthAnimationStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   usernameField.hidden = YES;
   passwordField.hidden = YES;
   proceedButton.hidden = YES;
   
   [self getToken];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchAll) name:@"didFetchAll" object:nil];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchAll" object:nil];   
}

- (IBAction) getToken
{
   [authActivity startAnimating];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   RTMAuth *auth = app.auth;
   NSString *frob = auth.frob;

   // get Token
   RTMAPIAuth *api_auth = [[[RTMAPIAuth alloc] init] autorelease];
   NSString *token = [api_auth getToken:frob];

   [authActivity stopAnimating];

   if (!token) {
      [self failedInAuthorization];
      return;
   }

   auth.token = token;
   [RTMAPI setToken:auth.token];
   [app.auth save];
}

- (void) didFetchAll
{
   instructionLabel.text = @"Done!";
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFetchAll" object:nil];
   [self performSelector:@selector(backToRootMenu) withObject:nil afterDelay:1.0f];
}   

- (void) backToRootMenu
{
   UINavigationController *nc = (UINavigationController *)self.parentViewController;
   UIViewController *vc = nc.topViewController;
   if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
      UITableViewController<ReloadableTableViewControllerProtocol> *tvc = (UITableViewController<ReloadableTableViewControllerProtocol> *)vc;
      [tvc reloadFromDB];
      [tvc.tableView reloadData];
   }
   [self dismissModalViewControllerAnimated:YES];   
}

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
   NSLog(@"authorizingPhase = %d", authorizeingPhase);
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
      result = [webView stringByEvaluatingJavaScriptFromString:@"var form = document.forms[0]; form ? 'form exist' : 'form not';"];
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
   NSLog(@"pageheader = %@", result);
   if ([result isEqualToString:@"Application successfully authorized"]) {
      NSAssert(state == STATE_SHOW_WEBVIEW || state == STATE_USERINFO_ENTERED, @"check state");
      state = STATE_DONE;
      [self didSucceedInAuth];
   }
}  

@end