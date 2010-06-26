//
//  RTMAPI+List.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI+List.h"
#import "RTMAPI.h"
#import "RTMAPIParserDelegate.h"

// -------------------------------------------------------------------
#pragma mark -
#pragma mark ListGetCallback
@interface ListGetCallback : RTMAPIParserDelegate
{
   enum {
      NONE,
      LIST,
      FILTER
   } mode;

   NSMutableDictionary *params;
   NSMutableArray      *lists;
   NSString            *text;
}
@end

@implementation ListGetCallback

- (void) reset
{
   mode = NONE;
   [params release];
   params = nil;
   text = @"";
}

- (id) init
{
   if (self = [super init]) {
      lists = [[NSMutableArray alloc] init];
      [self reset];
   }
   return self;
}

- (void) dealloc
{
   [params release];
   [lists release];
   [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;
   SKIP_RSP;

   if ([elementName isEqualToString:@"lists"]) { // start to parse
      NSAssert(mode == NONE, @"state check");
      return;
   }
   if ([elementName isEqualToString:@"list"]) {
      NSAssert(lists != nil && mode == NONE, @"state check");
      mode = LIST;
      params = [[NSMutableDictionary alloc] initWithDictionary:attributeDict];
      return;
   }

   if ([elementName isEqualToString:@"filter"]) {
      mode = FILTER;
      return;
   }

   NSAssert1(NO, @"not reach here: elementName=%@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   NSAssert(mode == FILTER, @"state check");
   text = [text stringByAppendingString:chars];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"list"]) {
      NSAssert2(mode == LIST, @"state check for %@, params=%@", elementName, params);
      [lists addObject:params];
      [self reset];
      return;
   }
   if ([elementName isEqualToString:@"filter"]) {
      NSAssert(mode == FILTER && params != nil, @"state check");
      [params setObject:text forKey:@"filter"];
      text = nil;
      mode = LIST;
   }
}

- (id) result
{
   return lists;
}

@end // ListGetCallback

// -------------------------------------------------------------------
#pragma mark -
#pragma mark ListAddCallback
@interface ListAddCallback : RTMAPIParserDelegate
{
   NSDictionary *list;
}
@end // ListAddCallback

@implementation ListAddCallback

- (id) init
{
   if (self = [super init]) {
      list = nil;
   }
   return self;
}

- (void) dealloc
{
   [list release];
   [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;

   if ([elementName isEqualToString:@"list"])
      list = [attributeDict retain];
}

- (id) result
{
   return list;
}

@end // ListAddCallback

// -------------------------------------------------------------------
#pragma mark -
#pragma mark ListFlagCheckCallback
@interface ListFlagCheckCallback : RTMAPIParserDelegate
{
   BOOL flagToCheck;
   NSString *flagName;
}
@end

@implementation ListFlagCheckCallback

- (id) init:(NSString *)name
{
   if (self = [super init]) {
      flagToCheck = NO;
      flagName = name;
   }
   return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;

   if ([elementName isEqualToString:@"list"])
      flagToCheck = (1 == [[attributeDict valueForKey:flagName] integerValue]);
}

- (id) result
{
   return flagToCheck ? self : nil;
}
@end

// -------------------------------------------------------------------
#pragma mark -
#pragma mark RTMAPIList

@implementation RTMAPI (List)

- (NSArray *) getList
{
   return (NSArray *)[self call:@"rtm.lists.getList" args:nil delegate:[[[ListGetCallback alloc] init] autorelease]];
}

- (NSDictionary *) add:(NSString *)name timeline:(NSString *)timeline filter:(NSString *)filter
{
   NSArray *keys = [NSArray arrayWithObjects:@"name", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:name, timeline, nil];

   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   if (filter)
      [args setObject:filter forKey:@"filter"];

   return [self call:@"rtm.lists.add" args:args delegate:[[[ListAddCallback alloc] init] autorelease]];
}

- (BOOL) delete:(NSString *)listID timeline:(NSString *)timeline
{
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:listID, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   return [self call:@"rtm.lists.delete" args:args delegate:[[[ListFlagCheckCallback alloc] init:@"deleted"] autorelease]] != nil;
}

- (NSDictionary *) setName:(NSString *)name list:(NSString *)listID timeline:(NSString *)timeline
{
   NSArray *keys = [NSArray arrayWithObjects:@"name", @"list_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:name, listID, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   return [self call:@"rtm.lists.setName" args:args delegate:[[[ListAddCallback alloc] init] autorelease]];
}

- (BOOL) archive:(NSString *)listID timeline:(NSString *)timeline
{
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:listID, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   return [self call:@"rtm.lists.archive" args:args delegate:[[[ListFlagCheckCallback alloc] init:@"archived"] autorelease]] != nil;
}

- (BOOL) unarchive:(NSString *)listID timeline:(NSString *)timeline
{
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:listID, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   return [self call:@"rtm.lists.unarchive" args:args delegate:[[[ListFlagCheckCallback alloc] init:@"archived"] autorelease]] == nil;
}

@end