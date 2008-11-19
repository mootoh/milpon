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
@interface ListGetCallback : RTMAPIXMLParserCallback {
  enum {
    LIST,
    FILTER
  } mode;

  NSMutableDictionary *params;
  NSMutableArray *lists;
  BOOL skip;
}

- (NSArray *)lists;

@end

@implementation ListGetCallback

- (NSArray *)lists
{
  return lists;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
  [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
  
  if ([elementName isEqualToString:@"lists"]) {
    lists = [NSMutableArray array];
    skip = NO;
  } else if ([elementName isEqualToString:@"list"]) {
    mode = LIST;
    // some filtering
    if (
      [[attributeDict valueForKey:@"name"] isEqualToString:@"Sent"] ||
      [[attributeDict valueForKey:@"smart"] isEqualToString:@"1"]) {
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
  if (FILTER != mode)
    @throw @"characters should be found in <filter>";
  [params setObject:chars forKey:@"filter"];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  if ([elementName isEqualToString:@"list"] && !skip) {
    [lists addObject:params];
  } else if ([elementName isEqualToString:@"filter"]) {
    mode = LIST;
  }
}
@end

/* -------------------------------------------------------------------
 * ListAddCallback
 */
@interface ListAddCallback : RTMAPIXMLParserCallback {
  NSString * iD;
}
@property (nonatomic, readonly) NSString * iD;
@end

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

@end

/* -------------------------------------------------------------------
 * ListAddCallback
 */
@interface ListDeleteCallback : RTMAPIXMLParserCallback
@end

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

- (NSString *) add:(NSString *)name withFilter:(NSString *)filter
{
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return nil;
	NSArray *keys = [NSArray arrayWithObjects:@"name", @"timeline", nil];
	NSArray *vals = [NSArray arrayWithObjects:name, timeline, nil];
	
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

- (BOOL) delete:(NSString *)list_id
{
	RTMAPI *api = [[[RTMAPI alloc] init] autorelease];
	NSString *timeline = [api createTimeline];
  if (! timeline) return NO;
	NSArray *keys = [NSArray arrayWithObjects:@"list_id", @"timeline", nil];
	NSArray *vals = [NSArray arrayWithObjects:list_id, timeline, nil];
	
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
