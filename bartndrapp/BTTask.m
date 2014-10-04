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
@dynamic forItem;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Task";
}

@end
