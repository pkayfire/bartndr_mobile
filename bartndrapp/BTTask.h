//
//  BTTask.h
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import <Parse/Parse.h>

#import "BTItem.h"

typedef NS_ENUM(NSInteger, TaskStatus) {
    TaskStatusCreated,
    TaskStatusInProgress,
    TaskStatusCompleted,
};

@interface BTTask : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

+ (BTTask *)createTaskForItemID:(NSString *)itemID;
+ (BFTask *)getNumOfTasksInQueue;

@property NSNumber *status;
@property BTItem *for_item;
@end
