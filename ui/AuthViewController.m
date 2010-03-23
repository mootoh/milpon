#import "AuthViewController.h"
#import "RTMAPI.h"
#import "RTMAPIAuth.h"
#import "RTMAuth.h"
#import "AppDelegate.h"
#import "AuthWebViewController.h"
#import "RTMAPI.h"
#import "ReloadableTableViewController.h"

@implementation AuthViewController

#define GREETING_LABEL_WIDTH 156
#define INSTRUCTION_LABEL_WIDTH 284

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
   [authActivity release];
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

- (IBAction) auth
{
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

   //self.navigationController.navigationBarHidden = NO;
   AuthWebViewController *authWebViewController = [[AuthWebViewController alloc] initWithNibName:nil bundle:nil];
   authWebViewController.url = authURL;
   authWebViewController.username = usernameField.text;
   authWebViewController.password = passwordField.text;
   
//   [self.navigationController pushViewController:authWebViewController animated:YES];
   [self presentModalViewController:authWebViewController animated:YES];
   [authWebViewController release];

   state = STATE_JUMPED;
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
   //[self.navigationController popViewControllerAnimated:YES];
   [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   if (state != STATE_JUMPED)
      return;

   [self getToken];
   
   self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];

}

- (void)viewDidAppear:(BOOL)animated
{
   self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];

   [super viewDidAppear:animated];
   if (state != STATE_JUMPED)
      return;

   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchAll) name:@"didFetchAll" object:nil];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchAll" object:nil];
}

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
