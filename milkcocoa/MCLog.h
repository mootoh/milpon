/*
 *  MCLog.h
 *  Milpon
 *
 *  Created by Motohiro Takayama on 2/19/11.
 *  Copyright 2011 deadbeaf.org. All rights reserved.
 *
 */

#ifdef DEBUG

#define MCLOG(...) NSLog(__VA_ARGS__)
#define MCLOG_METHOD NSLog(@"%s", __func__);
//NSLog(NSStringFromSelector(_cmd))

#else // DEBUG

#define MCLOG(...) ;
#define MCLOG_METHOD ;

#endif // DEBUG