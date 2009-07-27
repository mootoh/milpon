//
//  ConfigViewController.m
//  Milpon
//
//  Created by mootoh on 10/20/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "ConfigViewController.h"
#import "AppDelegate.h"

#define VERSION "$Id$"

@implementation ConfigViewController

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
   if (self = [super initWithNibName:nibName bundle:bundle]) {
      CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

      activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      activityIndicator.frame = CGRectMake(appFrame.size.width/2-32, appFrame.size.height/2, 64, 64);
      activityIndicator.hidesWhenStopped = YES;
      self.title = NSLocalizedString(@"Setting", @"");
   }
   return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
   [super viewDidLoad];

   [self.view addSubview:activityIndicator];

   UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   reloadButton.frame = CGRectMake(20, 32, 280, 32);
   [reloadButton setTitle:NSLocalizedString(@"RefreshAll", @"") forState:UIControlStateNormal];

   AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   [reloadButton addTarget:app action:@selector(fetchAll) forControlEvents:UIControlEventTouchDown];
   [self.view addSubview:reloadButton];

   UIButton *feedbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   feedbackButton.frame = CGRectMake(20, 96, 280, 32);
   [feedbackButton setTitle:NSLocalizedString(@"SendFeedback", @"") forState:UIControlStateNormal];
   [feedbackButton addTarget:self action:@selector(emailFeedback) forControlEvents:UIControlEventTouchDown];
   [self.view addSubview:feedbackButton];

   UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
         [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MilponIconSmall.png"]];
   UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
   iconImageView.center = CGPointMake(160, 96+32*2+28); // 132, 96+32*2, 57, 57);
   [self.view addSubview:iconImageView];
   [iconImage release];

   UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 96+32*2+28+28+12, 280, 32)];
   versionLabel.font = [UIFont systemFontOfSize:14];
   versionLabel.text = [NSString stringWithFormat:@"rev %s", VERSION];
   [self.view addSubview:versionLabel];
   [versionLabel release];

}

- (void)dealloc
{
   [activityIndicator release];
   [super dealloc];
}

- (IBAction) emailFeedback
{  
   NSString *subject = [NSString stringWithFormat:@"subject=Milpon Feedback %s", VERSION];
   NSString *mailto = [NSString stringWithFormat:@"mailto:mootoh@gmail.com?%@", [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   NSURL *url = [NSURL URLWithString:mailto];
   [[UIApplication sharedApplication] openURL:url];
}  

@end
