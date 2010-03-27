//
//  RTMAPIXMLParserCallback.m
//  Milpon
//
//  Created by mootoh on 9/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPIXMLParserCallback.h"
#import "RTMError.h"

@implementation RTMAPIXMLParserCallback
@synthesize succeeded, error;

- (id) init
{
   if (self = [super init]) {
      succeeded = NO;
      error = nil;
   }
   return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   if ([elementName isEqualToString:@"rsp"]) {
      succeeded = [[attributeDict valueForKey:@"stat"] isEqualToString:@"ok"];
   } else if ([elementName isEqualToString:@"err"]) {
      NSAssert(!succeeded, @"stat should be 'fail'");
      NSDictionary *user_info = [NSDictionary
         dictionaryWithObject:[attributeDict valueForKey:@"msg"]
                       forKey:NSLocalizedDescriptionKey];
      error = [NSError errorWithDomain:RTMAPIErrorDomain
                                  code:[[attributeDict valueForKey:@"code"] integerValue]
                              userInfo:user_info];
   }
}

@end
