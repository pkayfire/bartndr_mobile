//
//  BTStore.m
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTStore.h"
#import <Parse/PFObject+Subclass.h>

#import "BTItem.h"

@implementation BTStore

@dynamic store_name;
@dynamic store_description;
@dynamic image_url;
@dynamic UUID;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Store";
}

- (BFTask *)getItems
{
    BFTaskCompletionSource *getItemsCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    PFQuery *itemsQuery = [BTItem query];
    [itemsQuery whereKey:@"for_store" equalTo:self];
    [itemsQuery orderByAscending:@"name"];
    [itemsQuery setCachePolicy:kPFCachePolicyCacheElseNetwork];
    
    [itemsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [getItemsCompletionSource setResult:[objects mutableCopy]];
        } else {
            [getItemsCompletionSource setError:error];
        }
    }];
    
    return getItemsCompletionSource.task;
}

+ (BFTask *)getStoreForUUID:(NSString *)uuid
{
    BFTaskCompletionSource *getStoreCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    PFQuery *storeQuery = [BTStore query];
    [storeQuery whereKey:@"UUID" equalTo:uuid];
    [storeQuery setCachePolicy:kPFCachePolicyNetworkElseCache];
    
    [storeQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [getStoreCompletionSource setResult:object];
        } else {
            [getStoreCompletionSource setError:error];
        }
    }];

    return getStoreCompletionSource.task;
}

@end
