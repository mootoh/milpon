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
      LIST,
      FILTER
   } mode;

   NSMutableDictionary *params;
   NSMutableArray *lists;
   BOOL skip;
}

- (NSArray *)lists;

@end // ListGetCallback

@implementation ListGetCallback

- (NSArray *)lists
{
   return lists;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];

   if ([elementName isEqualToString:@"lists"]) { // start to parse
      lists = [NSMutableArray array];
      skip = NO;
   } else if ([elementName isEqualToString:@"list"]) {
      mode = LIST;
      // some filtering
      if ([[attributeDict valueForKey:@"name"] isEqualToString:@"Sent"] || [[attributeDict valueForKey:@"smart"] isEqualToString:@"1"]) {
         skip = YES;
      } else {
         skip = NO;
         params = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      }
   } else if ([elementName isEqualToString:@"filter"]) {
      mode = FILTER;
   }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   // check whethere chars contains white space only.
   const char *str = [chars UTF8String];
   int i=0, len=[chars length];
   for (; i<len; i++)
      if (! isspace(str[i])) break;
   if (i == len) return;

   NSAssert2(mode == FILTER, @"characters should be found in <filter> but in %@, chars=%@", mode, chars);
   [params setObject:chars forKey:@"filter"];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"list"] && !skip)
      [lists addObject:params];
   else if ([elementName isEqualToString:@"filter"])
      mode = LIST;
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
