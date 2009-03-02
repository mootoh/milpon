#import "AuthViewController.h"
#import "RTMAPI.h"
#import "RTMAPIAuth.h"
#import "RTMAuth.h"
#import "AppDelegate.h"
#import "AuthWebViewController.h"
#import "RTMAPI.h"
#import "RootViewController.h"

@implementation AuthViewController

@synthesize bottomBar, rootViewController;

#define GREETING_LABEL_WIDTH 156
#define INSTRUCTION_LABEL_WIDTH 284

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
   if (self = [super initWithNibName:nibName bundle:bundle]) {
      state = STATE_INITIAL;
      self.title = @"Setup";

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
      [doneButton setTitle:@"done" forState:UIControlStateNormal];
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
   instructionLabel.text = @"Milpon needs a permission to access your RTM data.\n\nGo and login to RTM site, then you will be asked whether you accept this app to access your data.\n\nAfter you admit, return here by pressing 'Setup' button on navigation bar.";

   [confirmButton setTitle:@"go to RTM" forState:UIControlStateNormal];
   [confirmButton addTarget:self action:@selector(auth) forControlEvents:UIControlEventTouchDown];
   confirmButton.enabled = YES;
   confirmButton.hidden = NO;
}

- (void) alertError
{
   UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"＞＜"
      message:@"could not get necessary information from RTM web site. please try again when you online."
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
   NSLog(@"navc = %p", self.navigationController);
   //[self.navigationController popViewControllerAnimated:YES];
   [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   if (state != STATE_JUMPED)
      return;

   instructionLabel.text = @"acquiring permission...";
   instructionLabel.textAlignment = UITextAlignmentCenter;

   [confirmButton removeTarget:self action:@selector(auth) forControlEvents:UIControlEventTouchDown];
   confirmButton.enabled = NO;
   confirmButton.hidden = YES;

   [self getToken];
   instructionLabel.text = @"fetching all lists, tasks...\nThis may take for a while. Be patient m(_ _)m";
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   if (state != STATE_JUMPED)
      return;

   [self.rootViewController fetchAll];

   instructionLabel.text = @"DONE !\n\nEnjoy :)";

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   NSTimer *timer;
   timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:app selector:@selector(authDone:) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
   if (STATE_DONE == state)
      self.bottomBar.hidden = NO;
}

@end
