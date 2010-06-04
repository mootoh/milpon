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
#import "logger.h"

// -------------------------------------------------------------------
#pragma mark -
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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
   
   if (! [elementName isEqualToString:@"rsp"])
      key = [elementName retain];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   [key release];
   key = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
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
@property (nonatomic, retain) NSString *string;
@end

@implementation GetStringCallback
@synthesize string;

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
   self.string = chars;
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
   NSDictionary *userInfo = (NSDictionary *)[self call:@"rtm.auth.checkToken" args:[NSDictionary dictionaryWithObject:tkn forKey:@"auth_token"] withDelegate:[[[GetDictionaryCallback alloc] init] autorelease]];
   return userInfo != nil;
}

/*
 * should return:
 * <?xml version="1.0" encoding="UTF-8"?>
 * <rsp stat="ok"><frob>6c38ecbb2b8925190518d6fb06eae57fdbbf22c3</frob></rsp>
 */
- (NSString *) getFrob
{
   return (NSString *)[self call:@"rtm.auth.getFrob" args:nil withDelegate:[[[GetStringCallback alloc] init] autorelease]];
}

- (NSString *) getToken:(NSString *)frob
{
   NSDictionary *userInfo = (NSDictionary *)[self call:@"rtm.auth.getToken" args:[NSDictionary dictionaryWithObject:frob forKey:@"frob"] withDelegate:[[[GetDictionaryCallback alloc] init] autorelease]];
   return [userInfo objectForKey:@"token"];
}

@end