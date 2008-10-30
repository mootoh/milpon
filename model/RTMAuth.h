//
//  RTMAuth.h
//  Milpon
//
//  Created by mootoh on 9/5/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

/**
 * holds authentication information.
 *
 * load/store information from/to database, 'auth' table.
 */
@interface RTMAuth : NSObject <NSCoding>
{
  NSString *api_key;
  NSString *shared_secret;
  NSString *frob;
  NSString *token;
}

@property (nonatomic, retain) NSString *api_key;
@property (nonatomic, retain) NSString *shared_secret;
@property (nonatomic, retain) NSString *frob;
@property (nonatomic, retain) NSString *token;

@end
