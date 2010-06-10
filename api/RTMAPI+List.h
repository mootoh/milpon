//
//  RTMAPI+List.h
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//
#import "RTMAPI.h"

@interface RTMAPI (List)

/**
 * call rtm.lists.add
 *
 * @return added list dictionary. if failed, exception will be raised.
 */
- (NSDictionary *) add:(NSString *)name timeline:(NSString *)timeline filter:(NSString *)filter;

/**
 * call rtm.lists.delete
 *
 * @return deletion has been done successfully or not.
 */
- (BOOL) delete:(NSString *)listID timeline:(NSString *)timeline;
/**
 * call rtm.lists.getList
 *
 * @return array of dictionaries containing list properties.
 *         if failed, return nil.
 */
- (NSArray *) getList;

#if 0
// -------------------------------------------------------------------
// not implemented yet.
//
/**
 * call rtm.lists.archive
 */
- (void) archive:(NSString *)list_id;
/**
 * call rtm.lists.setDefaultList
 *
 * won't implement this.
 */
- (void) setDefaultList:(NSString *)list_id;
/**
 * call rtm.lists.setName
 */
- (void) setName:(NSString *)name forList:(NSString *)list_id;
/**
 * call rtm.lists.unarchive
 */
- (void) unarchive:(NSString *)list_id;
#endif // 0
@end