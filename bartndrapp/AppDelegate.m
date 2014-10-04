//
//  AppDelegate.m
//  bartndrapp
//
//  Created by Peter Kim on 10/1/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "AppDelegate.h"

// Import Models
#import "BTTask.h"
#import "BTStore.h"
#import "BTItem.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

static NSString *beacon_one_UUID_string = @"8BDBDE7A-E3E2-4941-8F45-743B1CAF8758";
static NSString *beacon_two_UUID_string = @"6A39DE93-9826-4793-B978-DD7E3605644E";
static NSString *beacon_three_UUID_string = @"D4FB9ECE-59A7-4AFF-BDF0-6EFE9CFD1E5F";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Initialize Parse
    [Parse setApplicationId:@"n27hpGo5rFEzX4EBI4OODoThfhTKfi5PDj66ZAks"
                  clientKey:@"Qi9MzvPb8PwkVcxGHYT028ueluqvk5H7BpkTkoyk"];
    
    if (!self.currentStore) {
        self.currentStore = [BTStore objectWithoutDataWithClassName:@"Store" objectId:@"EeND5vfxv1"];
    }
    
    // Initialize CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    self.beaconUUID_one = [[NSUUID alloc] initWithUUIDString:beacon_one_UUID_string];
    CLBeaconRegion *beaconRegion_one = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconUUID_one major:1 minor:1 identifier:@"beacon_one"];
    beaconRegion_one.notifyOnEntry = YES;
    beaconRegion_one.notifyOnExit = YES;
    beaconRegion_one.notifyEntryStateOnDisplay = YES;
    
    self.beaconUUID_two = [[NSUUID alloc] initWithUUIDString:beacon_two_UUID_string];
    CLBeaconRegion *beaconRegion_two = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconUUID_two identifier:@"beacon_two"];
    beaconRegion_two.notifyOnEntry = YES;
    beaconRegion_two.notifyOnExit = YES;
    beaconRegion_two.notifyEntryStateOnDisplay = YES;
    
    self.beaconUUID_three = [[NSUUID alloc] initWithUUIDString:beacon_three_UUID_string];
    CLBeaconRegion *beaconRegion_three = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconUUID_three identifier:@"beacon_three"];
    beaconRegion_three.notifyOnEntry = YES;
    beaconRegion_three.notifyOnExit = YES;
    beaconRegion_three.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startMonitoringForRegion:beaconRegion_one];
    //[self.locationManager startMonitoringForRegion:beaconRegion_two];
    //[self.locationManager startMonitoringForRegion:beaconRegion_three];
    
    [self.locationManager startMonitoringForRegion:beaconRegion_one];
//    [self.locationManager startMonitoringForRegion:beaconRegion_two];
//    [self.locationManager startMonitoringForRegion:beaconRegion_three];
    
    NSLog(@"didFinishLaunchingWithOptions");
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.sentLocalPush = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Core Location Delegate Methods

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [manager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside) {
        //Start Ranging
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *) region;
            [manager startRangingBeaconsInRegion:beaconRegion];
            
            [[BTStore getStoreForUUID:beaconRegion.proximityUUID.UUIDString] continueWithBlock:^id(BFTask *task) {
                if (!task.error && task.result && !self.sentLocalPush) {
                    self.currentStore = (BTStore *) task.result;
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = [NSString stringWithFormat:@"Welcome to %@. Swipe now to order!", self.currentStore.store_name];
                    notification.soundName = @"Default";
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                    
                    self.sentLocalPush = YES;
                } else {
                    if (!task.error) { NSLog(@"Local Push already sent."); }
                    else { NSLog(@"%@", task.error); }
                }
                
                return nil;
            }];
        }
    } else {
        
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
//    NSLog(@"Found Beacons");
//    for (CLBeacon *beacon in beacons) {
//        NSLog(@"%@", beacon);
//    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"didEnterRegion!");
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Welcome to Maruchi's Inn! Swipe now to order!";
        notification.soundName = @"Default";
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

#pragma mark - Utility Methods

+ (AppDelegate *)get {
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

@end
