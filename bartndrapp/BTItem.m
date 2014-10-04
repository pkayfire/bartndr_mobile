//
//  BTItem.m
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTItem.h"
#import <Parse/PFObject+Subclass.h>

@implementation BTItem

@dynamic name;
@dynamic description;
@dynamic imageURL;

@dynamic forStore;

@dynamic price;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Item";
}

@end
