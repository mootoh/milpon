//
//  RTMAPIAuth.h
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMAPI.h"

@interface RTMAPI (Auth)

- (BOOL) checkToken:(NSString *)token;
- (NSString *) getFrob;
- (NSString *) getToken:(NSString *)frob;

@end