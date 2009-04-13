//
//  TrialNoteEditController.h
//  Milpon
//
//  Created by mootoh on 1/23/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "Milpon.h"

@interface NoteEditController : UIViewController
{
   IBOutlet UITextView *note_view;
   UIViewController <TaskEditDelegate> *parent;
   NSString *note;
}

@property (nonatomic,retain) UIViewController <TaskEditDelegate> *parent;
@property (nonatomic,retain) NSString *note;
@end
