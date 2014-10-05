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
@dynamic minorID;

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
    [itemsQuery orderByAscending:@"item_name"];
    [itemsQuery setCachePolicy:kPFCachePolicyNetworkElseCache];
    
    [itemsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"here");
        NSLog(@"%@", objects);
        if (!error) {
            [getItemsCompletionSource setResult:[objects mutableCopy]];
        } else {
            [getItemsCompletionSource setError:error];
        }
    }];
    
    return getItemsCompletionSource.task;
}

+ (BFTask *)getStoreForUUID:(NSString *)uuid
                 andMinorID:(NSString *)minorID
{
    BFTaskCompletionSource *getStoreCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    PFQuery *storeQuery = [BTStore query];
    [storeQuery whereKey:@"UUID" equalTo:uuid];
    [storeQuery whereKey:@"minorID" equalTo:minorID];
    [storeQuery setCachePolicy:kPFCachePolicyCacheElseNetwork];
    
    [storeQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [getStoreCompletionSource setResult:object];
        } else {
            [getStoreCompletionSource setError:error];
        }
    }];

    return getStoreCompletionSource.task;
}

+ (BFTask *)hasTasksToComplete
{
    BFTaskCompletionSource *hasTasksCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    return hasTasksCompletionSource.task;
}

@end
