//
//  RTMAPIXMLParserCallback.h
//  Milpon
//
//  Created by mootoh on 9/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

/**
 * base class for parsing RTM API response.
 *
 * care about 'rsp' error code.
 */
@interface RTMAPIXMLParserCallback : NSObject {
  BOOL succeeded;
  NSError *error;
}

@property (nonatomic, readonly) BOOL succeeded;
@property (nonatomic, readonly) NSError *error;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;

@end
