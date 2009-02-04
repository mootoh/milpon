//
//  TrialNoteEditController.h
//  Milpon
//
//  Created by mootoh on 1/23/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddTaskViewController;

@interface NoteEditController : UIViewController {
   IBOutlet UITextView *note_view;
   AddTaskViewController *parent;
   NSString *note;
}

@property (nonatomic,retain) AddTaskViewController *parent;
@property (nonatomic,retain) NSString *note;
@end
