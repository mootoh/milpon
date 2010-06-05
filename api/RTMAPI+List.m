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

/* -------------------------------------------------------------------
 * ListAddCallback
 */
@interface ListAddCallback : RTMAPIParserDelegate
{
   NSString * iD;
}
@end // ListAddCallback

@implementation ListAddCallback

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

   if ([elementName isEqualToString:@"list"]) {
      iD = [attributeDict valueForKey:@"id"];
      // [parser abortParsing]; // shortcut
   }
}

@end // ListAddCallback

/* -------------------------------------------------------------------
 * ListDeleteCallback
 */
@interface ListDeleteCallback : RTMAPIParserDelegate; @end

@implementation ListDeleteCallback

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

   if ([elementName isEqualToString:@"list"]) {
      if (1 != [[attributeDict valueForKey:@"deleted"] integerValue])
         @throw @"failed in deleting a list.";
   }
}

@end

// -------------------------------------------------------------------
#pragma mark -
#pragma mark RTMAPIList

@implementation RTMAPI (List)

- (NSArray *) getList
{
   return (NSArray *)[self call:@"rtm.lists.getList" args:nil withDelegate:[[[ListGetCallback alloc] init] autorelease]];
}

#if 0
- (NSString *) add:(NSString *)name withFilter:(NSString *)filter withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   NSArray *keys = [NSArray arrayWithObjects:@"name", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:name, timeLine, nil];

   NSMutableDictionary *args = [NSDictionary dictionaryWithObjects:vals
      forKeys:keys];
   if (filter)
      [args setObject:filter forKey:@"filter"];

   NSData *response = [api call:@"rtm.lists.add" withArgs:args];
   if (! response) return nil;

   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   ListAddCallback *cb = [[[ListAddCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   if (! [parser parse])
      @throw @"failed in parsing rtm.lists.add response.";
   return cb.iD;
}

- (BOOL) delete:(NSString *)list_id withTimeLine:(NSString *)timeLine
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"timeline", nil];
   NSArray *vals = [NSArray arrayWithObjects:list_id, timeLine, nil];

   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals
      forKeys:keys];

   NSData *response = [api call:@"rtm.lists.delete" withArgs:args];
   if (! response) return NO;

   method = LISTS_DELETE;
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   ListDeleteCallback *cb = [[[ListAddCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   if (! [parser parse])
      @throw @"failed in parsing rtm.lists.add response.";

   return YES;
}
#endif // 0
@end