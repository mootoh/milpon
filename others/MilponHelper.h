//
//  MilponHelper.h
//  Milpon
//
//  Created by mootoh on 2/19/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MilponHelper : NSObject
{
   NSDateFormatter *the_formatter;
   NSDate *invalidDate;
}

@property (nonatomic,assign) NSDate *invalidDate;

+ (MilponHelper *) sharedHelper;

/**
  * format NSDate to NSString with custom DateFormatter.
  */
- (NSString *) dateToString:(NSDate *) date;
- (NSDate *) stringToDate:(NSString *) str;

- (NSString *) dateToRtmString:(NSDate *) date;
- (NSDate *) rtmStringToDate:(NSString *) str;

@end
