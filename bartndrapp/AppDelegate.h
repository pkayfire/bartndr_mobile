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

@property CLBeaconRegion *beaconRegion;

@property BTStore *currentStore;
@property BOOL sentLocalPush;

@property NSSTring *braintreeClientToken;

+ (AppDelegate *)get;

@end

