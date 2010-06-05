//
//  RTMAPI+Timeline.m
//  Milpon
//
//  Created by Motohiro Takayama on 6/4/10.
//  Copyright 2010 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"
#import "RTMAPI+Timeline.h"
#import "RTMAPIParserDelegate.h"

@interface RTMAPITimeLineDelegate : RTMAPIParserDelegate
{
   NSString *timeline;
}

@end

@implementation RTMAPITimeLineDelegate

- (id) init
{
   if (self = [super init]) {
      timeline = nil;
   }
   return self;
}

- (void) dealloc
{
   [timeline release];
   [super dealloc];
}

#pragma mark -
#pragma mark RTMAPIDelegate

- (id) result
{
   return timeline;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"timeline"])
      NSAssert(timeline, @"timeline should be obtained");
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   [timeline release];
   timeline = [chars retain];
}

@end

@implementation RTMAPI (Timeline)

- (NSString *) createTimeline
{
   return (NSString *)[self call:@"rtm.timelines.create" args:[NSDictionary dictionaryWithObject:self.token forKey:@"auth_token"] withDelegate:[[[RTMAPITimeLineDelegate alloc] init] autorelease]];
}

@end