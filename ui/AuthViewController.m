#import "AuthViewController.h"
#import "RTMAPI.h"
#import "RTMAPIAuth.h"
#import "RTMAuth.h"
#import "AppDelegate.h"
#import "AuthWebViewController.h"
#import "RTMAPI.h"
#import "ReloadableTableViewController.h"

@implementation AuthViewController

@synthesize bottomBar;

#define GREETING_LABEL_WIDTH 156
#define INSTRUCTION_LABEL_WIDTH 284

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
   if (self = [super initWithNibName:nibName bundle:bundle]) {
      state = STATE_INITIAL;
      self.title = NSLocalizedString(@"Setup", "setup screen");

      CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

      /*
       * greeting
       */
      greetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(appFrame.size.width/2-GREETING_LABEL_WIDTH/2, 32, GREETING_LABEL_WIDTH, 48)];
      greetingLabel.font = [UIFont systemFontOfSize:48];
      greetingLabel.text = @"Milpon";

      /*
       * instruction
       */
      instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(appFrame.size.width/2-INSTRUCTION_LABEL_WIDTH/2, 110, INSTRUCTION_LABEL_WIDTH, 176)];
      //instructionLabel.backgroundColor = [UIColor grayColor];
      instructionLabel.font = [UIFont systemFontOfSize:16];
      instructionLabel.lineBreakMode = UILineBreakModeWordWrap;
      instructionLabel.numberOfLines = 9;

      /*
       * button
       */
      confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      confirmButton.frame = CGRectMake(appFrame.size.width/2-150/2, 300, 150, 40);
      [confirmButton retain];

      authActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      authActivity.frame = CGRectMake(appFrame.size.width/2-16, appFrame.size.height/2, 32, 32);
      authActivity.hidesWhenStopped = YES;

#ifdef DEBUG
      UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      doneButton.frame = CGRectMake(appFrame.size.width/2-150/2, 350, 150, 40);
      [doneButton setTitle:NSLocalizedString(@"Done", @"done button") forState:UIControlStateNormal];
      [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchDown];
      doneButton.enabled = YES;
      doneButton.hidden = NO;
      [self.view addSubview:doneButton];
#endif // DEBUG

      [self greet];
   }
   return self;
}

- (void) dealloc
{
   [greetingLabel release];
   [instructionLabel release];
   [authActivity release];
   [confirmButton release];
   [super dealloc];
}

- (void) loadView
{
   [super loadView];

   self.view.backgroundColor = [UIColor whiteColor];

   // TODO: add funny image
   [self.view addSubview:greetingLabel];
   [self.view addSubview:instructionLabel];
   [self.view addSubview:confirmButton];
   [self.view addSubview:authActivity];
}

- (void) greet
{
   state = STATE_INITIAL;

   instructionLabel.textAlignment = UITextAlignmentLeft;
   instructionLabel.text = NSLocalizedString(@"AuthNaviFirst", @"first auth navigation message");

   [confirmButton setTitle:NSLocalizedString(@"GoToRTM", @"go to RTM button") forState:UIControlStateNormal];
   [confirmButton addTarget:self action:@selector(auth) forControlEvents:UIControlEventTouchDown];
   confirmButton.enabled = YES;
   confirmButton.hidden = NO;
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

   //self.navigationController.navigationBarHidden = NO;
   AuthWebViewController *authWebViewController = [[AuthWebViewController alloc] initWithNibName:nil bundle:nil];
   authWebViewController.url = authURL;
   [self.navigationController pushViewController:authWebViewController animated:YES];
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
      [self greet];
      return;
   }

   auth.token = token;
   [RTMAPI setToken:auth.token];
   [app saveAuth];
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

   instructionLabel.text = NSLocalizedString(@"AcquiringPermission", @"permission getting screen");
   instructionLabel.textAlignment = UITextAlignmentCenter;

   [confirmButton removeTarget:self action:@selector(auth) forControlEvents:UIControlEventTouchDown];
   confirmButton.enabled = NO;
   confirmButton.hidden = YES;

   [self getToken];
   instructionLabel.text = NSLocalizedString(@"FetchingInstruction", @"fetch all data");
   
   self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];

}

- (void)viewDidAppear:(BOOL)animated
{
   self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0f/256.0f green:102.0f/256.0f blue:153.0f/256.0f alpha:1.0];

   [super viewDidAppear:animated];
   if (state != STATE_JUMPED)
      return;

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   [app fetchAll];

   instructionLabel.text = NSLocalizedString(@"InitDone", @"all initial process has been succeeded");

   NSTimer *timer;
   timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(done:) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
   if (STATE_DONE == state) {
      self.bottomBar.hidden = NO;

      UIViewController *vc = ((UINavigationController *)self.navigationController.parentViewController).topViewController;
      if ([vc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
         UITableViewController <ReloadableTableViewControllerProtocol> *tvc = (UITableViewController <ReloadableTableViewControllerProtocol> *)vc;
         [tvc reloadFromDB];
         [tvc.tableView reloadData];
      }
   }
}

@end
