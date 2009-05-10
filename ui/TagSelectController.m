//
//  TagSelectController.m
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "TagSelectController.h"
#import "TagProvider.h"
#import "AddTaskViewController.h"
#import "RTMTag.h"

@implementation TagSelectController

@synthesize parent, selected_tags, all_tags;

static UIImage *s_checkedIcon = nil;

+ (UIImage *)checkedIcon
{
   if (s_checkedIcon == nil)
      s_checkedIcon = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_checked.png"]];
   return s_checkedIcon;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
      tag_provider = [[TagProvider sharedTagProvider] retain];
      self.all_tags = [tag_provider tags];
      self.title = @"Tags";
      selected_flags = [[NSMutableDictionary alloc] init];
   }
   return self;
}

- (void)dealloc
{
   [all_tags release];
   [selected_flags release];
   [tag_provider release];
   [super dealloc];
}

- (void) setTags:(NSMutableSet *) tags
{
   self.selected_tags = tags;
   for (RTMTag *tag in all_tags) {
      // KRDS start: should use NSSet:member or NSSet:containsObject
      //   instead of O(N) loop
      //   (but that does not work for this)
#if 0
      id has = [selected_tags containsObject:tag];
#endif // 0
      BOOL has = NO;
      for (RTMTag *tg in selected_tags)
         if ([tg isEqual:tag]) {
            has = YES;
            break;
         }
      // KRDS end
      [selected_flags setObject:[NSNumber numberWithBool:has] forKey:tag.name];
   }      
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return all_tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagSelectConrtollerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }

   RTMTag *tag = [all_tags objectAtIndex:indexPath.row];
   cell.text = tag.name;
   
   if ([[selected_flags objectForKey:tag.name] boolValue]) {
      UIImageView *image_view = [[UIImageView alloc] initWithImage:[TagSelectController checkedIcon]];
      cell.accessoryView = image_view;
      [image_view release];
   } else {
      cell.accessoryView = nil;
   }
   
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   RTMTag *tag = [all_tags objectAtIndex:indexPath.row];
   if ([[selected_flags objectForKey:tag.name] boolValue]) {
      [selected_flags setObject:[NSNumber numberWithBool:NO] forKey:tag.name];
      
      for (RTMTag *tg in selected_tags) {
         NSLog(@"tg = %d, %@", tg.iD, tg.name);
      }
      [selected_tags removeObject:tag]; // FIXME: if the pointers of RTMTag in all_tags and selected_tags are not equal, removeObject does not remove the tag unexpectedly.
   } else {
      [selected_flags setObject:[NSNumber numberWithBool:YES] forKey:tag.name];
      [selected_tags addObject:tag];
   }
   [tableView reloadData]; // TODO: should update only selected row.
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self.parent setTag:selected_tags]; // TODO: should reload only tag row
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}

@end