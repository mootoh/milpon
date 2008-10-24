//
//  MockRTMAPI.m
//  Milpon
//
//  Created by mootoh on 9/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "MockRTMAPI.h"

@implementation MockRTMAPI

+ (void) setApiKey:(NSString *)key
{
}

+ (NSString *) apiKey
{
	return @"apiKey";
}

+ (void) setSecret:(NSString *)sec
{
}

+ (NSString *) secret
{
	return @"secret";
}

- (NSData *) call:(NSString *)method withArgs:(NSDictionary *)args
{
	return [NSData data];
}

- (NSString *)path:(NSString *)method withArgs:(NSDictionary *)args
{
	return @"path";
}

- (NSString *)sign:(NSString *)method withArgs:(NSDictionary *)args
{
	return @"sign";
}

- (NSString *) authURL:(NSString *)frob forPermission:(NSString *)perm
{
	return @"authURL";
}

- (NSString *) createTimeline:(NSString *)token
{
	return @"timeline";
}


@end

