//
//  MCParserDelegate.h
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
@interface MCParserDelegate : NSObject <NSXMLParserDelegate>
{
   BOOL     succeeded;
   NSError *error;

   NSString *echoResult;
   NSMutableDictionary *response;

   NSString *currentKey, *currentValue;
}

@property (nonatomic, readonly) NSMutableDictionary *response;
@property (nonatomic, readonly) NSError *error;

@end

#pragma mark -
#pragma mark helper macros
#define SUPER_PARSE [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict]
#define SKIP_RSP if ([elementName isEqualToString:@"rsp"]) return
