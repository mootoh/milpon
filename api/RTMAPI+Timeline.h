//
//  RTMAPI+Timeline.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/4/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMAPI.h"

@interface RTMAPITimeLineDelegate : NSObject <RTMAPIDelegate>
{
   NSString *timeline;
}

@end

@interface RTMAPI (Timeline)

/**
 * @brief call RTM API 'rtm.timelines.create'.
 * @note  this method is not reentrant.
 */
- (NSString *) createTimeline;

@end