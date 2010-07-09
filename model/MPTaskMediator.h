//
//  MPTaskMediator.h
//  Milpon
//
//  Created by Motohiro Takayama on 6/27/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "MPMediator.h"

@interface MPTaskMediator : MPMediator

- (void) deleteRemotelyDeletedItems:(NSArray *)taskSerieses;

@end