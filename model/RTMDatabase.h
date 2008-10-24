//
//  RTMDatabase.h
//  Milpon
//
//  Created by mootoh on 8/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <sqlite3.h>

/**
 * intended to wrap sqlite access, but have not done yet.
 * currently it only hides the implementation detail of database path.
 */
@interface RTMDatabase : NSObject {
	sqlite3  *handle;
  NSString *path;
}

@property (nonatomic, readonly) sqlite3 *handle;
@property (nonatomic, readonly) NSString *path;
@end
