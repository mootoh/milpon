//
//  DBNoteProvider.h
//  Milpon
//
//  Created by mootoh on 2/27/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "NoteProvider.h"

@class LocalCache;

@interface DBNoteProvider : NoteProvider
{
   LocalCache *local_cache_;
}
@end
