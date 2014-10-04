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

@property NSMutableArray *menuItems;

@property CWStatusBarNotification *statusBarNotification;


@end
