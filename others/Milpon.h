/*
 *  Milpon.h
 *  Milpon
 *
 *  Created by mootoh on 4/13/09.
 *  Copyright 2009 deadbeaf.org. All rights reserved.
 *
 */

@protocol TaskEditDelegate

- (void) setDue:(NSDate *)date;
- (void) setNote:(NSString *)note;
- (void) updateView;

@end

@class RTMList;

@protocol HavingList

- (void) setList:(RTMList *)list;

@end
