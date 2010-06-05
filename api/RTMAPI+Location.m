//
//  RTMAPI+Location.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/6/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RTMAPI+Location.h"
#import "RTMAPIParserDelegate.h"

// -------------------------------------------------------------------
#pragma mark -
#pragma mark LocationGetCallback
@interface LocationGetCallback : RTMAPIParserDelegate
{
   NSMutableSet *locations;
   NSString     *text;
}
@end

@implementation LocationGetCallback

- (void) reset
{
   text = @"";
}

- (id) init
{
   if (self = [super init]) {
      locations = [[NSMutableSet alloc] init];
      [self reset];
   }
   return self;
}

- (void) dealloc
{
   [locations release];
   [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;
   if ([elementName isEqualToString:@"location"]) {
      [locations addObject:attributeDict];
      return;
   }
}

- (id) result
{
   return locations;
}

@end // LocationGetCallback

@implementation RTMAPI (Location)

- (NSSet *) getLocations
{
   return [self call:@"rtm.locations.getList" args:nil withDelegate:[[[LocationGetCallback alloc] init] autorelease]];
}

@end