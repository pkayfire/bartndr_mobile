//
//  BTItem.m
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTItem.h"
#import <Parse/PFObject+Subclass.h>

#import "BTTask.h"

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

+ (BFTask *)processItems:(NSMutableDictionary *)items
{
    BFTaskCompletionSource *processItemsCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    
    for (id key in items) {
        BTItem *item = (BTItem *)key;
        NSNumber *quantity = [items objectForKey:item];
        NSNumber *counter = @0;
        
        while (counter < quantity) {
            BTTask *task = [BTTask createTaskForItem:item];
            [tasks addObject:task];
            counter = [NSNumber numberWithInt:[counter intValue] + 1];
        }
    }
    
    [PFObject saveAllInBackground:tasks block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [processItemsCompletionSource setResult:[NSNumber numberWithBool:succeeded]];
        } else {
            [processItemsCompletionSource setError:error];
        }
    }];
    
    return processItemsCompletionSource.task;
}

@end
