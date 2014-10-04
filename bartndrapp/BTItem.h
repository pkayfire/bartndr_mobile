//
//  BTItem.h
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import <Parse/Parse.h>

#import "BTStore.h"

@interface BTItem : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString* name;
@property NSString* description;
@property NSString* imageURL;

@property BTStore* forStore;

@property NSNumber* price;

@end
