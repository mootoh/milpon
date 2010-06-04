//
//  RTMAPIAuth.h
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"

typedef enum {
  RTM_PERM_READ,
  RTM_PERM_WRITE,
  RTM_PERM_DELETE
} RTMPermission;


/** ------------------------------------------------------------------
 * RTMAPIAuth
 */
@interface RTMAPIAuth : NSObject {
}

- (BOOL) checkToken:(NSString *)token;

/**
 * should return:
 * <?xml version="1.0" encoding="UTF-8"?>
 * <rsp stat="ok"><frob>6c38ecbb2b8925190518d6fb06eae57fdbbf22c3</frob></rsp>
 */
- (NSString *) getFrob;
- (NSString *) getToken:(NSString *)frob;
@end

// vim:set ft=objc:
