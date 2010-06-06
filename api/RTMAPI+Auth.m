//
//  RTMAPIAuth.m
//  Milpon
//
//  Created by mootoh on 8/27/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"
#import "RTMAPI+Auth.h"
#import "RTMAPIParserDelegate.h"
#import "MPLogger.h"

// -------------------------------------------------------------------
#pragma mark GetDictionaryCallback

@interface GetDictionaryCallback : RTMAPIParserDelegate
{
   NSString            *key;
   NSMutableDictionary *dict;
}
@end

@implementation GetDictionaryCallback

- (id) init
{
   if (self = [super init]) {
      dict = [[NSMutableDictionary alloc] init];
      key  = nil;
   }
   return self;
}

- (void) dealloc
{
   [key release];
   [dict release];
   [super dealloc];
}

- (id) result
{
   return dict;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;
   SKIP_RSP;
   
   key = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   key = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   NSAssert(key, @"state check");
   [dict setObject:chars forKey:key];
}

@end

// -------------------------------------------------------------------
#pragma mark -
#pragma mark GetStringCallback

@interface GetStringCallback : RTMAPIParserDelegate
{
   NSString *string;
}
@end

@implementation GetStringCallback

- (id) init
{
   if (self = [super init]) {
      string = nil;
   }
   return self;
}

- (void) dealloc
{
   [string release];
   [super dealloc];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   if (string) [string release];
   string = [chars retain];
   [parser abortParsing];
}

- (id) result
{
   return string;
}
@end

// -------------------------------------------------------------------
#pragma mark -
#pragma mark RTMAPI (Auth)

@implementation RTMAPI (Auth)

- (BOOL) checkToken:(NSString *)tkn
{
   NSDictionary *userInfo = (NSDictionary *)[self call:@"rtm.auth.checkToken" args:[NSDictionary dictionaryWithObject:tkn forKey:@"auth_token"] delegate:[[[GetDictionaryCallback alloc] init] autorelease]];
   return userInfo != nil;
}

/*
 * should return:
 * <?xml version="1.0" encoding="UTF-8"?>
 * <rsp stat="ok"><frob>6c38ecbb2b8925190518d6fb06eae57fdbbf22c3</frob></rsp>
 */
- (NSString *) getFrob
{
   return (NSString *)[self call:@"rtm.auth.getFrob" args:nil delegate:[[[GetStringCallback alloc] init] autorelease]];
}

- (NSString *) getToken:(NSString *)frob
{
   NSDictionary *userInfo = (NSDictionary *)[self call:@"rtm.auth.getToken" args:[NSDictionary dictionaryWithObject:frob forKey:@"frob"] delegate:[[[GetDictionaryCallback alloc] init] autorelease]];
   return [userInfo objectForKey:@"token"];
}

@end