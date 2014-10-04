//
//  BTStore.m
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTStore.h"
#import <Parse/PFObject+Subclass.h>

@implementation BTStore

@dynamic name;
@dynamic description;
@dynamic imageURL;
@dynamic UUID;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Store";
}

@end
