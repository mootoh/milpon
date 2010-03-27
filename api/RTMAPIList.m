//
//  RTMAPIList.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPIList.h"
#import "RTMAPI.h"
#import "RTMList.h"
#import "RTMAPIXMLParserCallback.h"

/* -------------------------------------------------------------------
 * ListGetCallback
 */
@interface ListGetCallback : RTMAPIXMLParserCallback
{
   enum {
      NONE,
      LIST,
      FILTER
   } mode;

   NSMutableDictionary *params;
   NSMutableArray *lists;
   NSString *text;
   BOOL skip;
}

@property (nonatomic, readonly) NSMutableArray *lists;

@end // ListGetCallback

@implementation ListGetCallback
@synthesize lists;

- (void) reset
{
   mode = NONE;
   params = nil;
   skip = NO;
   text = @"";
}

- (id) init
{
   if (self = [super init]) {
      lists = nil;
      [self reset];
   }
   return self;
}

- (NSArray *)lists
{
   return lists;
}

// filter out 'Sent' and smart lists.
// TODO: also skip archived list
- (BOOL) shouldSkip:(NSDictionary *)attributeDict
{
   return [[attributeDict valueForKey:@"name"] isEqualToString:@"Sent"]
       || [[attributeDict valueForKey:@"archived"] isEqualToString:@"1"]
       || [[attributeDict valueForKey:@"deleted"] isEqualToString:@"1"];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

   if ([elementName isEqualToString:@"lists"]) { // start to parse
      NSAssert(lists == nil && mode == NONE, @"state check");
      lists = [NSMutableArray array];
      return;
   }
   if ([elementName isEqualToString:@"list"]) {
      NSAssert(lists != nil && mode == NONE, @"state check");
      mode = LIST;
      if ([self shouldSkip:attributeDict]) {
         skip = YES;
         return;
      }

      skip = NO;
      params = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      return;
   }

   if ([elementName isEqualToString:@"filter"]) {
      if (skip) return;
      mode = FILTER;
   }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   if (skip) return;
   NSAssert(mode == FILTER, @"state check");
   text = [text stringByAppendingString:chars];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"list"]) {
      NSAssert(mode == LIST, @"state check");
      if (! skip)
         [lists addObject:params];
      [self reset];
   } else if ([elementName isEqualToString:@"filter"]) {
      if (skip) return;
      NSAssert(mode == FILTER && params != nil, @"state check");
      [params setObject:text forKey:@"filter"];
      text = nil;
      mode = LIST;
   }
}
@end // ListGetCallback

/* -------------------------------------------------------------------
 * ListAddCallback
 */
@interface ListAddCallback : RTMAPIXMLParserCallback
{
   NSString * iD;
}

@property (nonatomic, readonly) NSString * iD;
@end // ListAddCallback

@implementation ListAddCallback

@synthesize iD;

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
@interface ListDeleteCallback : RTMAPIXMLParserCallback; @end

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

/* -------------------------------------------------------------------
 * RTMAPIList
 */
@implementation RTMAPIList

- (NSArray *) getList
{
   RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
   NSData *response = [api call:@"rtm.lists.getList" withArgs:nil];
   if (! response) return nil;

   method = LISTS_GETLIST;
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:response] autorelease];
   ListGetCallback *cb = [[[ListGetCallback alloc] init] autorelease];
   [parser setDelegate:cb];
   if (! [parser parse])
      @throw @"failed in parsing rtm.lists.getList response.";
   return [cb lists];
}

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

@end
