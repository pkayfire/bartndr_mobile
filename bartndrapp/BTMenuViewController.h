//
//  BTMenuViewController.h
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CWStatusBarNotification.h"

@interface BTMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UIButton *checkOutButton;

- (IBAction)handleCheckOut:(id)sender;
- (void)updateCheckOutButton;

@property NSMutableArray *menuItems;

@property CWStatusBarNotification *statusBarNotification;
@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;

@end
