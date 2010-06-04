//
//  RTMAPIXMLParserCallback.h
//  Milpon
//
//  Created by mootoh on 9/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//
#import <UIKit/UIKit.h>

/**
 * base class of parsers for RTM API response,
 * only cares about 'rsp' result code.
 */
@interface RTMAPIParserDelegate : NSObject {
   BOOL succeeded;
   NSError *error;
}

@property (nonatomic, readonly) NSError *error;

- (id) result; //!< result of the API call.

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;

@end