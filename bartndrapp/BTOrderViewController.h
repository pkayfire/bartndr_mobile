//
//  BTOrderViewController.h
//  bartndrapp
//
//  Created by Peter Kim on 10/4/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStatusBarNotification.h"

@interface BTOrderViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;

@property CWStatusBarNotification *statusBarNotification;

@property NSMutableDictionary *selectedMenuItems;
@property NSMutableDictionary *itemObjectIDToBTItem;

@property (weak, nonatomic) IBOutlet UITableView *menuItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *placeOrderButton;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

- (IBAction)handlePlaceOrderButton:(id)sender;
- (IBAction)handleBackButton:(id)sender;

@end
