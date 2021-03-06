//
//  DBNoteProvider.m
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DBNoteProvider.h"
#import "RTMNote.h"
#import "RTMTask.h"
#import "LocalCache.h"

@implementation DBNoteProvider

- (id) init
{
   if (self = [super init])
      local_cache_ = [LocalCache sharedLocalCache];
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (NSArray *) notesInTask:(NSInteger) task_id
{
   NSMutableArray *ret = [NSMutableArray array];
   NSArray *keys = [NSArray arrayWithObjects:@"note.id", @"note.title", @"note.text", @"note.task_id", @"note.edit_bits", @"note.note_id", nil];
   NSDictionary *note_opts = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"task_id=%d", task_id] forKey:@"WHERE"];
   NSArray *notes = [local_cache_ select:keys from:@"note" option:note_opts];
   for (NSDictionary *attr in notes) {
      RTMNote *note = [[RTMNote alloc] initByAttributes:attr];
      [ret addObject:note];
      [note release];
   }
   return ret;
}

- (NSArray *) modifiedNotes
{
   NSMutableArray *ret = [NSMutableArray array];
   NSArray *keys = [NSArray arrayWithObjects:@"note.id", @"note.title", @"note.text", @"note.task_id", @"note.edit_bits", @"note.note_id", nil];
   NSDictionary *cond = [NSDictionary dictionaryWithObject:@"edit_bits>0" forKey:@"WHERE"];
   NSArray *notes = [local_cache_ select:keys from:@"note" option:cond];
   for (NSDictionary *attr in notes) {
      RTMNote *note = [[RTMNote alloc] initByAttributes:attr];
      [ret addObject:note];
      [note release];
   }
   return ret;
}

- (void) createNoteAtOnline:(NSString *)text title:(NSString *)title task_id:(NSInteger)task_id note_id:(NSInteger)note_id
{
   NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"task_id", @"text", @"note_id", nil];
   NSMutableArray *vals = [NSMutableArray arrayWithObjects:
                           [NSNumber numberWithInteger:task_id],
                           text == nil ? @"" : text,
                           [NSNumber numberWithInteger:note_id],
                           nil];

   if (! [title isEqualToString:@""]) {
      [keys addObject:@"title"];
      [vals addObject:title];
   }

   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [local_cache_ insert:attrs into:@"note"];
}

- (NSNumber *) createAtOffline:(NSString *)note inTask:(NSInteger) task_id
{
   NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"task_id", @"edit_bits", nil];
   NSMutableArray *vals = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:task_id], [NSNumber numberWithInt:EB_CREATED_OFFLINE], nil];

   NSMutableArray *note_elms = [NSMutableArray arrayWithArray:[note componentsSeparatedByString:@"\n"]];
   if (note_elms.count > 1) {
      [keys addObject:@"title"];
      [vals addObject:[note_elms objectAtIndex:0]];
      [note_elms removeObjectAtIndex:0];
   }

   NSString *note_text = @"";
   for (NSString *pieces in note_elms)
      note_text = [note_text stringByAppendingString:[pieces stringByAppendingString:@"\n"]];

   [keys addObject:@"text"];
   [vals addObject:note_text];

   NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   [local_cache_ insert:attrs into:@"note"];
   
   NSArray *iid = [NSArray arrayWithObject:@"id"];
   NSDictionary *order = [NSDictionary dictionaryWithObject:@"id DESC LIMIT 1" forKey:@"ORDER"]; // TODO: ad-hoc LIMIT
   NSArray *ret = [local_cache_ select:iid from:@"note" option:order];
   NSNumber *retn = [[ret objectAtIndex:0] objectForKey:@"id"];
   return retn;
}
   
- (void) update:(RTMNote *)note text:(NSString *)text
{
   NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"edit_bits", nil];
   NSMutableArray *vals = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:EB_NOTE_MODIFIED], nil];
   
   NSMutableArray *note_elms = [NSMutableArray arrayWithArray:[text componentsSeparatedByString:@"\n"]];
   [keys addObject:@"title"];
   if (note_elms.count > 1) {
      [vals addObject:[note_elms objectAtIndex:0]];
      [note_elms removeObjectAtIndex:0];
   } else {
      [vals addObject:[NSNull null]];
   }
   
   NSString *note_text = @"";
   for (NSString *pieces in note_elms)
      note_text = [note_text stringByAppendingString:[pieces stringByAppendingString:@"\n"]];
   
   [keys addObject:@"text"];
   [vals addObject:note_text];
   
   NSDictionary *dict = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   NSString *where = [NSString stringWithFormat:@"WHERE id=%d", note.iD];
   
   [[LocalCache sharedLocalCache] update:dict table:@"note" condition:where];
}

- (void) remove:(NSInteger) note_id
{
   NSString *cond = [NSString stringWithFormat:@"WHERE id = %d", note_id];
   [local_cache_ delete:@"note" condition:cond];
}

- (void) removeForTask:(RTMTask *) task
{
   NSString *cond = [NSString stringWithFormat:@"WHERE task_id=%d", task.iD];
   [local_cache_ delete:@"note" condition:cond];
}

@end // DBNoteProvider

@implementation NoteProvider (DB)

static DBNoteProvider *s_db_list_provider = nil;

+ (NoteProvider *) sharedNoteProvider
{
   if (nil == s_db_list_provider)
      s_db_list_provider = [[DBNoteProvider alloc] init];
   return s_db_list_provider; 
}

@end // NoteProvider (Mock)
