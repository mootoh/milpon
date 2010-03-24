#import "AuthViewController.h"
#import "RTMAPI.h"
#import "RTMAPIAuth.h"
#import "RTMAuth.h"
#import "AppDelegate.h"
#import "AuthWebViewController.h"
#import "RTMAPI.h"
#import "ReloadableTableViewController.h"

@implementation AuthViewController

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
   if (self = [super initWithNibName:nibName bundle:bundle]) {
      state = STATE_INITIAL;
      self.title = NSLocalizedString(@"Setup", "setup screen");
      authWebViewController = nil;

      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailInAuth) name:@"didFailInAuth" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedInAuth) name:@"didSucceedInAuth" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAuthWebView) name:@"presentAuthWebView" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDismissWebView) name:@"didDismissWebView" object:nil];
   }
   return self;
}

- (void) dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFailInAuth" object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSucceedInAuth" object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"presentAuthWebView" object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didDismissWebView" object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFetchAll" object:nil];

   [authWebViewController release];
//   [proceedButton release];
//   [authActivity release];
//   [usernameField release];
//   [passwordField release];
//   [instructionLabel release];
   [super dealloc];
}

- (void) alertError
{
   UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"＞＜"
      message:NSLocalizedString(@"AuthError", @"error in RTM site auth.")
      delegate:nil
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil];
   [av show];
   [av release];
}

- (IBAction) proceedToAuthorization
{
   instructionLabel.text = @"Press OK button in the next screen.";
   
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
      [self alertError];
      return;
   }

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   RTMAuth *auth = app.auth;
   auth.frob = frob;

   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   NSString *urlString = [api authURL:frob forPermission:@"delete"];
   NSURL *authURL = [NSURL URLWithString:urlString];

   NSLog(@"authURL = %@", authURL);

   authWebViewController = [[AuthWebViewController alloc] initWithNibName:nil bundle:nil];
   authWebViewController.url = authURL;
   authWebViewController.username = usernameField.text;
   authWebViewController.password = passwordField.text;

   [authWebViewController startLoading];
//   [self presentModalViewController:authWebViewController animated:YES];

   state = STATE_JUMPED;
}

- (void) didFailInAuth
{
   NSLog(@"failed in auth");
   instructionLabel.text = @"Login failed.";
   [authWebViewController stop];

   [usernameField becomeFirstResponder];
   usernameField.enabled = YES;
   passwordField.enabled = YES;
   proceedButton.enabled = YES;
   [authActivity stopAnimating];
   
   [authWebViewController dismissModalViewControllerAnimated:YES];
   [authWebViewController release];
}

- (void) didSucceedInAuth
{
   NSLog(@"succeeded in auth");
   instructionLabel.text = @"Loading Tasks...";
   [authWebViewController stop];
   [authWebViewController dismissModalViewControllerAnimated:YES];
}

- (void) didDismissWebView
{
   [authWebViewController release];

   [self getToken];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchAll) name:@"didFetchAll" object:nil];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchAll" object:nil];
}

- (void) presentAuthWebView
{
   NSLog(@"present Auth WebView");
   [self presentModalViewController:authWebViewController animated:YES];
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
      [self alertError];
      return;
   }

   auth.token = token;
   [RTMAPI setToken:auth.token];
   [app.auth save];
}

- (void) done:(NSTimer*)theTimer
{
   state = STATE_DONE;
   [self dismissModalViewControllerAnimated:YES];

   UINavigationController *nc = (UINavigationController *)self.parentViewController;
   UIViewController *vc = nc.topViewController;
   if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
      UITableViewController<ReloadableTableViewControllerProtocol> *tvc = (UITableViewController<ReloadableTableViewControllerProtocol> *)vc;
      [tvc reloadFromDB];
      [tvc.tableView reloadData];
   }
   
}

- (void) viewDidLoad
{
   [super viewDidLoad];
   [usernameField becomeFirstResponder];
}

/*
- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   if (state != STATE_JUMPED)
      return;
}
*/
/*
- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   if (state != STATE_JUMPED)
      return;
}
*/
- (void) didFetchAll
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFetchAll" object:nil];
   
   NSTimer *timer;
   timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(done:) userInfo:nil repeats:NO];
}   


- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
   if (STATE_DONE == state) {
      UIViewController *vc = ((UINavigationController *)self.navigationController.parentViewController).topViewController;
      if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
         UITableViewController <ReloadableTableViewControllerProtocol> *tvc = (UITableViewController <ReloadableTableViewControllerProtocol> *)vc;
         [tvc reloadFromDB];
         [tvc.tableView reloadData];
      }
   }
}

@end
