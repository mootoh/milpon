//
//  AddTaskViewController.m
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "AddTaskViewController.h"
#import "ListSelectController.h"
#import "TagSelectController.h"
#import "NoteEditController.h"
#import "DueDateSelectController.h"
#import "ReloadableTableViewController.h"
#import "AppDelegate.h"
#import "RTMTask.h"
#import "RTMList.h"
#import "RTMTag.h"
#import "TaskProvider.h"
#import "ListProvider.h"
#import "TagProvider.h"
#import "NoteProvider.h"
#import "logger.h"

@implementation AddTaskViewController

enum {
   ROW_NAME = 0,
   ROW_DUE_PRIORITY,
   ROW_LIST,
   ROW_TAG,
   ROW_NOTE,
   ROW_COUNT
};

@synthesize list, due, tags, note, task_name;

- (id)initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
      self.title = NSLocalizedString(@"Add", @"");
      self.list  = [[ListProvider sharedListProvider] inboxList];
      self.tags  = [NSMutableArray array];
      name_text_field = [[UITextField alloc] initWithFrame:CGRectMake(30, 8, 300, 40)];
   }
   return self;
}

- (void)dealloc
{
   if (priority_segment_) [priority_segment_ release];
   [name_text_field release];
   [super dealloc];
}

- (void) viewDidLoad
{
   self.tableView.rowHeight = 40;
   
   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
   self.navigationItem.leftBarButtonItem = cancelButton;
   [cancelButton release];

   UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
   self.navigationItem.rightBarButtonItem = submitButton;
   [submitButton release];
}

- (void) didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return ROW_COUNT;
}

enum {
   ICON_TAG = 1,
   LABEL_TAG,
   DUE_BUTTON_TAG,
   NAME_FIELD_TAG,
   PRIORITY_SEGMENT_TAG,
   ICON_IMAGE_VIEW_TAG
};

#define NAME_CELL_IDENTIFIER @"NameCell"
#define DUE_PRIORITY_CELL_IDENTIFIER @"DuePriorityCell"
#define ICON_LABEL_CELL_IDENTIFIER @"IconLabelCell"
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   UITableViewCell *cell = nil;

   switch (indexPath.row) {
      case ROW_NAME: {
         cell = [tableView dequeueReusableCellWithIdentifier:NAME_CELL_IDENTIFIER];
         if (cell == nil) {
            cell = [[[UITableViewCell alloc]
                     initWithFrame:CGRectZero reuseIdentifier:NAME_CELL_IDENTIFIER] autorelease];
            UIImageView *icon_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 16, 16)];
            UIImage *icon_image = [[UIImage alloc] initWithContentsOfFile:
                                  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_target.png"]];
            icon_image_view.image = icon_image;
            [icon_image release];
            [cell.contentView addSubview:icon_image_view];
            [icon_image_view release];
            
            // task name
            [name_text_field setFont:[UIFont systemFontOfSize:20.0f]];
            name_text_field.placeholder = NSLocalizedString(@"WhatToDo", @"");
            name_text_field.tag = NAME_FIELD_TAG;
            name_text_field.delegate = self;
            if (task_name)
               name_text_field.text = task_name;

            [cell.contentView addSubview:name_text_field];
         }
         [name_text_field becomeFirstResponder];
         break;
      }
      case ROW_DUE_PRIORITY: {
         cell = [tableView dequeueReusableCellWithIdentifier:DUE_PRIORITY_CELL_IDENTIFIER];
         UIButton *due_button = nil;
         UISegmentedControl *priority_segment = nil;
         if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:DUE_PRIORITY_CELL_IDENTIFIER] autorelease];
            
            // due button
            due_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            due_button.frame = CGRectMake(8, 4, 84, 32);
            due_button.font = [UIFont systemFontOfSize:14];
            
            UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                                  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_calendar.png"]];
            [due_button setImage:iconImage forState:UIControlStateNormal];
            [due_button addTarget:self action:@selector(selectDue) forControlEvents:UIControlEventTouchDown];
            due_button.tag = DUE_BUTTON_TAG;
            [iconImage release];

            [cell.contentView addSubview:due_button];

            // setup priority segment
            NSArray *priority_items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
            priority_segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(104, 4, CGRectGetWidth(self.view.frame)-104-10, 32)];
            for (int i=0; i<priority_items.count; i++)
               [priority_segment insertSegmentWithTitle:[priority_items objectAtIndex:i] atIndex:i animated:NO];
            
            priority_segment.selectedSegmentIndex = 3;
            priority_segment.tag = PRIORITY_SEGMENT_TAG;
            [cell.contentView addSubview:priority_segment];
            [priority_segment release];
         } else {
            due_button = (UIButton *)[cell viewWithTag:DUE_BUTTON_TAG];
            priority_segment = (UISegmentedControl *)[cell viewWithTag:PRIORITY_SEGMENT_TAG];
         }
         priority_segment_ = [priority_segment retain];

         if (self.due) {
            NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
            date_formatter.dateFormat = @" MM/dd";
            
            NSString *due_string = [date_formatter stringFromDate:self.due];
            [due_button setTitle:due_string forState:UIControlStateNormal];
            [date_formatter release];
         }         
         break;
      }
      default: {
         UILabel *label = nil;
         UIImageView *icon_image_view = nil;

         cell = [tableView dequeueReusableCellWithIdentifier:ICON_LABEL_CELL_IDENTIFIER];
         if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:ICON_LABEL_CELL_IDENTIFIER] autorelease];

            icon_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 16, 16)];
            icon_image_view.tag = ICON_IMAGE_VIEW_TAG;
            [cell.contentView addSubview:icon_image_view];
            [icon_image_view release];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(30, 2, 220, 36)];
            label.tag = LABEL_TAG;
            [cell.contentView addSubview:label];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;            
         } else {
            icon_image_view = (UIImageView *)[cell.contentView viewWithTag:ICON_IMAGE_VIEW_TAG];
            label = (UILabel *)[cell.contentView viewWithTag:LABEL_TAG];
         }
         
         switch (indexPath.row) {
            case ROW_LIST: {
               UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]];
               icon_image_view.image = iconImage;
               [iconImage release];
               label.text = list.name;
               break;
            }
            case ROW_TAG: {
               UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]];
               icon_image_view.image = iconImage;
               [iconImage release];

               // join tags
               NSString *tags_joined = @"";
               if (tags.count == 0) {
                  tags_joined = NSLocalizedString(@"Tag", @"");
               } else {
                  for (RTMTag *tag in tags)
                     tags_joined = [tags_joined stringByAppendingString:[NSString stringWithFormat:@"%@ ", tag.name]];
               }
               
               label.text = tags_joined;
               break;
            }
            case ROW_NOTE: {
               UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                                     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_note.png"]];
               icon_image_view.image = iconImage;
               [iconImage release];
               
               label.text = note ? note : NSLocalizedString(@"Note", @"");
               break;
            }
         }
         break;
      }
   }
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   switch (indexPath.row) {
      case ROW_DUE_PRIORITY:
         [tableView deselectRowAtIndexPath:indexPath animated:NO];
         break;
      case ROW_LIST: {
         ListSelectController *vc = [[ListSelectController alloc] initWithNibName:nil bundle:nil];
         vc.parent = self;
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      case ROW_TAG: {
         TagSelectController *vc = [[TagSelectController alloc] initWithNibName:nil bundle:nil];
         vc.parent = self;
         [vc setTags:tags];
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      case ROW_NOTE: {
         NoteEditController *vc = [[NoteEditController alloc] initWithNibName:nil bundle:nil];
         vc.parent = self;
         vc.note = note;
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      default:
         break;
   }
   [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) close
{
   UINavigationController *tbc = (UINavigationController *)self.navigationController.parentViewController;
   UITableViewController *tvc = (UITableViewController *)tbc.topViewController;
   if ([tvc conformsToProtocol:@protocol(ReloadableTableViewControllerProtocol)]) {
      [(UITableViewController<ReloadableTableViewControllerProtocol> *)tvc reloadFromDB];
      [tvc.tableView reloadData];
   }
   
   [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) save
{
   if ([name_text_field.text isEqualToString:@""]) // validate name_field
      return;

   NSNumber *priority = [NSNumber numberWithInteger:priority_segment_.selectedSegmentIndex + 1];

   // create RTMTask and store it in DB.
   NSArray *keys = [NSArray arrayWithObjects:@"name", @"list_id", @"priority", nil];
   NSArray *vals = [NSArray arrayWithObjects:name_text_field.text, [NSNumber numberWithInteger:list.iD], priority, nil];
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   if (due)
      [params setObject:due forKey:@"due"];

   TaskProvider *tp = [TaskProvider sharedTaskProvider];
   NSNumber *tid = [tp createAtOffline:params];

   for (RTMTag *tag in tags)
      [[TagProvider sharedTagProvider] createRelation:tid tag_id:tag.iD];

   if (note)
      [[NoteProvider sharedNoteProvider] createAtOffline:note inTask:[tid integerValue]];

   [self close];
}

- (void) selectDue
{
   DueDateSelectController *vc = [[DueDateSelectController alloc] initWithNibName:nil bundle:nil];
   vc.parent = self;
   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
}

- (IBAction) cancel
{
   [self close];
}

- (void) updateView
{
   [self.tableView reloadData]; // TODO: should reload due row only.
}

- (void) setTag:(NSArray *) tags
{
   [self updateView];
}

@end
