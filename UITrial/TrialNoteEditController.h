//
//  TrialNoteEditController.h
//  Milpon
//
//  Created by mootoh on 1/23/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrialAddTaskViewController;

@interface TrialNoteEditController : UIViewController {
   IBOutlet UITextView *note_view;
   TrialAddTaskViewController *parent;
   NSString *note;
}

@property (nonatomic,retain) TrialAddTaskViewController *parent;
@property (nonatomic,retain) NSString *note;
@end
