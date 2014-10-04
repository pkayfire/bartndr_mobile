//
//  BTMenuViewController.m
//  bartndrapp
//
//  Created by Peter Kim on 10/3/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTMenuViewController.h"
#import "BTTableViewCell.h"

#import "AppDelegate.h"

#import "BTItem.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface BTMenuViewController ()

@property NSMutableDictionary *selectedMenuItems;

@end

@implementation BTMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if ([[AppDelegate get] currentStore]) {
        //[self setTitle:[[[AppDelegate get] currentStore] store_name]];
    }
    
    self.statusBarNotification = [CWStatusBarNotification new];
    self.statusBarNotification.notificationLabelBackgroundColor = [UIColor whiteColor];
    self.statusBarNotification.notificationLabelTextColor = [UIColor blackColor];
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    self.menuItems = [[NSMutableArray alloc] init];
    self.selectedMenuItems = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self.storeImageView sd_setImageWithURL:[NSURL URLWithString:@"http://drinks.seriouseats.com/images/2013/06/20130604-novela-4.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder_store"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [self updateMenuItems];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    [self updateMenuItems];
}

- (void)updateMenuItems
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.50 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.statusBarNotification displayNotificationWithMessage:@"Refreshing Menu..." completion:nil];
    });
    
    [[[[AppDelegate get] currentStore] getItems] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            self.menuItems = (NSMutableArray *)task.result;
            [self.menuTableView reloadData];
            
            //[self setTitle:[[[AppDelegate get] currentStore] store_name]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.statusBarNotification dismissNotification];
            });
        } else {
            NSLog(@"%@", task.error);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.statusBarNotification dismissNotification];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.statusBarNotification displayNotificationWithMessage:@"An error occured!" forDuration:2.5];
            });
        }
        return nil;
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BTTableViewCell";
    BTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[BTTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    BTItem *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.text = menuItem.item_name;
    cell.descriptionLabel.text = menuItem.item_description;
    cell.priceLabel.text = [NSString stringWithFormat:@"$%@", menuItem.price];
    cell.itemObjectID = menuItem.objectId;
    cell.selectedMenuItems = self.selectedMenuItems;
    cell.menuTableView = self.menuTableView;
    
    NSNumber *quantity = [self.selectedMenuItems objectForKey:[menuItem objectId]];
    
    if (quantity) {
        cell.quantityLabel.text = [NSString stringWithFormat:@"%@", quantity];
    } else {
        cell.quantityLabel.text = @"0";
    }
    
    [cell.itemImageView sd_setImageWithURL:[NSURL URLWithString:@"http://scontent-a.cdninstagram.com/hphotos-xaf1/t51.2885-15/10632396_338122119691992_62189954_n.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder_store"]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleCheckOut:(id)sender {
    [self.checkOutButton setUserInteractionEnabled:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.statusBarNotification displayNotificationWithMessage:@"Checking Out..." completion:nil];
    });
    
    [[BTItem processItems:[self.selectedMenuItems mutableCopy]] continueWithBlock:^id(BFTask *task) {
        [self.selectedMenuItems removeAllObjects];
        [self.menuTableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.statusBarNotification dismissNotification];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.checkOutButton setUserInteractionEnabled:YES];
            [self.statusBarNotification displayNotificationWithMessage:@"Check Out Complete!" forDuration:2.5];
        });

        return nil;
    }];
}

@end
