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

@property NSString* name;
@property NSString* description;
@property NSString* imageURL;
@property NSString* UUID;

@end
