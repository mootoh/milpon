#import "RTMTask.h"
#import "RTMExistingTask.h"
#import "RTMPendingTask.h"

@implementation RTMTask

@synthesize name, url, due, completed, priority, postponed, estimate, rrule, tags, notes, list_id, location_id;


- (id) initByParams:(NSDictionary *)params inDB:(RTMDatabase *)ddb 
{
   if (self = [super initByID:[params valueForKey:@"id"] inDB:ddb]) {
      self.name            = [params valueForKey:@"name"];
      self.url             = [params valueForKey:@"url"];
      self.due             = [params valueForKey:@"due"];
      self.location_id     = [params valueForKey:@"location_id"];
      self.completed       = [params valueForKey:@"completed"];
      self.priority        = [params valueForKey:@"priority"];
      self.postponed       = [params valueForKey:@"postponed"];
      self.estimate        = [params valueForKey:@"estimate"];
   }
   return self;
}

+ (NSArray *) tasks:(RTMDatabase *)db
{
   NSArray * tsks = [RTMExistingTask tasks:db];
   return [tsks arrayByAddingObjectsFromArray:[RTMPendingTask tasks:db]];
}

@end // RTMTask
