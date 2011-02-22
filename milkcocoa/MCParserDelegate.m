//
//  MCParserDelegate.m
//  Milpon
//
//  Created by mootoh on 9/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "MilkCocoa.h"
#import "MCParserDelegate.h"

@implementation MCParserDelegate
@synthesize response;
@synthesize error;

- (id) init
{
   if (self = [super init]) {
      succeeded = NO;
      error = nil;
      response = [[NSMutableDictionary alloc] init];
      currentKey = nil;
      currentValue = nil;
   }
   return self;
}

- (void) dealloc
{
   if (error) [error release];
   [response release];
   [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   if ([elementName isEqualToString:@"rsp"]) {
      succeeded = [[attributeDict valueForKey:@"stat"] isEqualToString:@"ok"];
   } else if ([elementName isEqualToString:@"err"]) {
      NSAssert(!succeeded, @"rsp:stat should be 'fail'");

      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[attributeDict valueForKey:@"msg"] forKey:NSLocalizedDescriptionKey];
      error = [NSError errorWithDomain:k_MC_ERROR_DOMAIN
                                  code:[[attributeDict valueForKey:@"code"] integerValue]
                              userInfo:userInfo];
      [parser abortParsing];
   } else {
      NSAssert(succeeded, @"should be in rsp element");

      currentKey = elementName;
      currentValue = @"";
   }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"rsp"] || [elementName isEqualToString:@"err"])
      return;

   [response setObject:currentValue forKey:currentKey];
   currentKey = nil;
   currentValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
   currentValue = [currentValue stringByAppendingString:string];
}

#pragma mark MCXMLParserDelegate

- (id) result
{
   return response;
}

- (NSError *) error
{
   return error;
}

@end
