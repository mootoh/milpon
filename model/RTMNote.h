//
//  RTMNote.h
//  Milpon
//
//  Created by mootoh on 10/3/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

@interface RTMNote : NSObject {
	NSInteger iD;
	NSString *created;
	NSString *modified;
	NSString *title;
	NSString *body;
	NSInteger task_id;
}

@property (nonatomic) NSInteger iD;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *modified;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic) NSInteger task_id;

- (id) init:(NSInteger)iD created:(NSString *)created modified:(NSString *)modified title:(NSString *)title task_id:(NSInteger)task_id;
@end
