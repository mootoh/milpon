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
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];

   MCTestEchoXMLParserDelegate *parserDelegate = [[MCTestEchoXMLParserDelegate alloc] init];
   MCRequest *req = [[MCRequest alloc] initWithToken:nil method:@"rtm.test.echo" parameters:nil parserDelegate:parserDelegate callback:^(NSError *err, id res) {
      if (err)
         callback(err, nil);
      else
         callback(nil, res);

      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];
//   [[MCCenter defaultCenter] addRequst:req];
   [req send];

   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];

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

   MCRequest *req = [[MCRequest alloc] initWithToken:nil method:@"rtm.auth.checkToken" parameters:[NSDictionary dictionaryWithObject:token forKey:@"auth_token"] parserDelegate:parserDelegate callback:^(NSError *err, id res) {
      if (err)
         callback(err, FALSE);
      else
         callback(nil, res == nil);
   }];
   [[MCCenter defaultCenter] addRequst:req];
   [parserDelegate release];
}

+ (void) getFrob:(void (^)(NSError *error, NSString *frob))callback
{
   __block BOOL finished = NO;
   NSCondition *condition = [[NSCondition alloc] init];
   MCParserDelegate *parserDelegate = [[MCParserDelegate alloc] init];

   MCRequest *req = [[MCRequest alloc] initWithToken:nil method:@"rtm.auth.getFrob" parameters:nil parserDelegate:parserDelegate callback:^(NSError *err, id res) {
      if (err)
         callback(err, nil);
      else
         callback(nil, [res objectForKey:@"frob"]);

      [condition lock];
      finished = YES;
      [condition signal];
      [condition unlock];
   }];
   [[MCCenter defaultCenter] addRequst:req];
   [parserDelegate release];

   [condition lock];
   while (! finished)
      [condition wait];
   [condition unlock];

   [req release];   
}

@end // Auth
// vim:set expandtab:sw=3:fdm=marker:
