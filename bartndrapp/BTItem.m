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

@dynamic item_name;
@dynamic item_description;
@dynamic image_url;

@dynamic for_store;

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
