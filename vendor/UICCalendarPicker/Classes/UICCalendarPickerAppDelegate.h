#import <UIKit/UIKit.h>
#import "UICCalendarPickerViewController.h"

@interface UICCalendarPickerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UICCalendarPickerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UICCalendarPickerViewController *viewController;

@end

