#import "MilkCocoa.h"
#import "MCRequest.h"
#import "MCParserDelegate.h"
#import "MCLog.h"
#import "PrivateInfo.h"

@implementation MilkCocoa
@end

@implementation MilkCocoa (Test)

+ (void) echo:(void (^)(NSError *, NSDictionary *))callback
{
   MCTestEchoXMLParserDelegate *parserDelegate = [[MCTestEchoXMLParserDelegate alloc] init];
   MCRequest *req = [[MCRequest alloc] initWithToken:nil method:@"rtm.test.echo" parameters:nil parserDelegate:parserDelegate callback:^(NSError *err, id res) {
      if (err)
         callback(err, nil);
      else
         callback(nil, res);
   }];
   [[MCCenter defaultCenter] addRequst:req];
   [parserDelegate release];
   [req release];
}

@end // Test


@implementation MilkCocoa (List)
+ (void) getList:(void (^)(NSError *error, NSArray *lists))callback
{
   MCListGetListXMLParserDelegate *parserDelegate = [[MCListGetListXMLParserDelegate alloc] init];

   MCRequest *req = [[MCRequest alloc] initWithToken:RTM_TOKEN_R method:@"rtm.lists.getList" parameters:nil parserDelegate:parserDelegate callback:callback];
   [[MCCenter defaultCenter] addRequst:req];
   [parserDelegate release];
}

@end // List


@implementation MilkCocoa (Auth)

+ (void) checkToken:(NSString *)token callback:(void (^)(NSError *error, BOOL isValid))callback
{
   MCParserDelegate *parserDelegate = [[MCParserDelegate alloc] init];
   MCRequest *req = [[MCRequest alloc] initWithToken:token method:@"rtm.auth.checkToken" parameters:nil parserDelegate:parserDelegate callback:^(NSError *err, id res) {
      if (err)
         callback(err, FALSE);
      else
         callback(nil, res == nil);
   }];
   [[MCCenter defaultCenter] addRequst:req];
   [parserDelegate release];
   [req release];
}

+ (void) getFrob:(void (^)(NSError *error, NSString *frob))callback
{
   MCParserDelegate *parserDelegate = [[MCParserDelegate alloc] init];
   MCRequest *req = [[MCRequest alloc] initWithToken:nil method:@"rtm.auth.getFrob" parameters:nil parserDelegate:parserDelegate callback:^(NSError *err, id res) {
      if (err)
         callback(err, nil);
      else
         callback(nil, [res objectForKey:@"frob"]);
   }];

   [[MCCenter defaultCenter] addRequst:req];
   [parserDelegate release];
   [req release];
}

+ (void) getToken:(NSString *)frob callback:(void (^)(NSError *error, NSString *frob))callback
{
   MCParserDelegate *parserDelegate = [[MCParserDelegate alloc] init];
   MCRequest *req = [[MCRequest alloc] initWithToken:nil
                                              method:@"rtm.auth.getToken"
                                          parameters:[NSDictionary dictionaryWithObject:frob forKey:@"frob"]
                                      parserDelegate:parserDelegate callback:^(NSError *err, id res) {
      if (err)
         callback(err, nil);
      else
         callback(nil, [res objectForKey:@"token"]);
   }];

   [[MCCenter defaultCenter] addRequst:req];
   [parserDelegate release];
   [req release];
}

@end // Auth
// vim:set expandtab:sw=3:fdm=marker:
