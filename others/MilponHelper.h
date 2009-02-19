//
//  MilponHelper.h
//  Milpon
//
//  Created by mootoh on 2/19/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

@interface MilponHelper : NSObject
{
   NSDateFormatter *the_formatter;
}

+ (MilponHelper *) sharedHelper;

/**
  * format NSDate to NSString with custom DateFormatter.
  */
- (NSString *) dateToString:(NSDate *) date;

@end