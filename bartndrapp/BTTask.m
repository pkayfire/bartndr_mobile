//
//  BTTask.m
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTTask.h"
#import <Parse/PFObject+Subclass.h>

#import "BTItem.h"

@implementation BTTask

@dynamic status;
@dynamic for_item;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Task";
}

+ (BTTask *)createTaskForItemID:(NSString *)itemID;
{
    BTTask *task = [[BTTask alloc] init];
    task.status = [NSNumber numberWithInt:TaskStatusCreated];
    task.for_item = [BTItem objectWithoutDataWithClassName:@"Item" objectId:itemID];
    
    return task;
}

+ (BFTask *)getNumOfTasksInQueue
{
    BFTaskCompletionSource *numOfTasksCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    PFQuery *numOfTasksInQueue = [BTTask query];
    [numOfTasksInQueue whereKey:@"status" equalTo:[NSNumber numberWithInt:TaskStatusCreated]];
    
    [numOfTasksInQueue countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [numOfTasksCompletionSource setResult:[NSNumber numberWithInt:number]];
        } else {
            [numOfTasksCompletionSource setError:error];
        }
    }];
    
    return numOfTasksCompletionSource.task;
}

@end
