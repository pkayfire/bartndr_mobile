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

+ (BFTask *)processItems:(NSMutableDictionary *)items;

@property NSString *item_name;
@property NSString *item_description;
@property NSString *image_url;

@property BTStore *for_store;

@property NSNumber *price;

@end
