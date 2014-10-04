//
//  AppDelegate.h
//  bartndrapp
//
//  Created by Peter Kim on 10/1/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "BTStore.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property NSUUID *beaconUUID_one;
@property NSUUID *beaconUUID_two;
@property NSUUID *beaconUUID_three;

@property BTStore *currentStore;

@property BOOL sentLocalPush;

+ (AppDelegate *)get;

@end

