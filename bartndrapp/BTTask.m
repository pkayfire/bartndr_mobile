//
//  BTTask.m
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTTask.h"
#import <Parse/PFObject+Subclass.h>

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

+ (BTTask *)createTaskForItem:(BTItem *)item
{
    BTTask *task = [[BTTask alloc] init];
    task.status = TaskStatusCreated;
    task.for_item = item;
    
    return task;
}

@end
