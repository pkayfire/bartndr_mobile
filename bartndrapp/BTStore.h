//
//  BTStore.h
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import <Parse/Parse.h>

@interface BTStore : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *store_name;
@property NSString *store_description;
@property NSString *image_url;
@property NSString *UUID;
@property NSString *minorID;

- (BFTask *)getItems;

+ (BFTask *)getStoreForUUID:(NSString *)uuid
                 andMinorID:(NSString *)minorID;

@end
