#import "RTMTask.h"
#import "RTMList.h"
#import "RTMTag.h"
#import "TaskProvider.h"
#import "TagProvider.h"
#import "MilponHelper.h"
#import "LocalCache.h"
#import "NoteProvider.h"
#import "logger.h"

@implementation RTMTask

DEFINE_ATTRIBUTE_RO(task_id, NSNumber*);
DEFINE_ATTRIBUTE_RO(taskseries_id, NSNumber*);
DEFINE_ATTRIBUTE_RO(url, NSString*);
DEFINE_ATTRIBUTE(priority, Priority, NSNumber*, EB_TASK_PRIORITY);
DEFINE_ATTRIBUTE(name, Name, NSString*, EB_TASK_NAME);
DEFINE_ATTRIBUTE(location_id, Location_id, NSNumber*, EB_TASK_LOCACTION_ID);
DEFINE_ATTRIBUTE(estimate, Estimate, NSString*, EB_TASK_ESTIMATE);
DEFINE_ATTRIBUTE(postponed, Postponed, NSNumber*, EB_TASK_POSTPONED);
DEFINE_ATTRIBUTE(rrule, Rrule, NSString*, EB_TASK_RRULE);
DEFINE_ATTRIBUTE(to_list_id, To_list_id, NSNumber*, EB_TASK_LIST_ID);

- (NSNumber *) list_id
{
   NSNumber *tli = self.to_list_id;
   return tli ? tli : [self attribute:@"list_id"];
}

- (BOOL) is_completed
{
   return [attrs_ objectForKey:@"task.completed"] != [NSNull null];
}

- (NSDate *) dateAttribute:(NSString *)name
{
   id dt = [self attribute:name];
   return dt ? [[MilponHelper sharedHelper] stringToDate:dt] : nil;
}

- (void) setDateAttribute:(NSDate *) dt forName:(NSString *)name editBits:(NSInteger) eb
{
   NSString *date_str = [[MilponHelper sharedHelper] dateToString:dt];
   [self setAttribute:date_str forName:name editBits:eb];
}

- (NSDate *) due
{
   return [self dateAttribute:@"due"];
}

- (void) setDue:(NSDate *)du
{
   return [self setDateAttribute:du forName:@"due" editBits:EB_TASK_DUE];
}

- (NSDate *) completed
{
   return [self dateAttribute:@"completed"];
}

- (void) setCompleted:(NSDate *)ct
{
   ct = ((NSNull *)ct == [NSNull null]) ? nil : ct;
   return [self setAttribute:ct forName:@"completed" editBits:EB_TASK_COMPLETED];
}

- (NSArray *) tags
{
   return [[TagProvider sharedTagProvider] tagsInTask:self.iD];
}

- (NSArray *) notes
{
   return [[NoteProvider sharedNoteProvider] notesInTask:self.iD];
}

- (void) complete
{
   self.completed = [NSDate date];
}

- (void) uncomplete
{
   self.completed = (NSDate *)[NSNull null];
}

- (void) setList:(RTMList *) list
{
   self.to_list_id = [NSNumber numberWithInteger:list.iD];
   [self flagUpEditBits:EB_TASK_LIST_ID];
}

- (void) setTags:(NSArray *)tags
{
   [[TagProvider sharedTagProvider] removeRelationForTask:self.iD];
   for (RTMTag *tag in tags)
      [[TagProvider sharedTagProvider] createRelation:[NSNumber numberWithInteger:self.iD] tag_id:tag.iD];
   [self flagUpEditBits:EB_TASK_TAG];
}

+ (NSString *) table_name
{
   return @"task";
}

@end // RTMTask