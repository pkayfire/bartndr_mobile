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

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface BTMenuViewController ()

@property NSMutableDictionary *selectedMenuItems;

@end

@implementation BTMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[AppDelegate get] currentStore]) {
        [[[AppDelegate get] currentStore] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSLog(@"%@", object);
            } else {
                
            }
        }];
    }
    
    UIColor *bartndrRed = [UIColor colorWithRed:233.0/255.0f green:55.0/255.0f blue:41.0/255.0f alpha:1.0f];
    
    self.statusBarNotification = [CWStatusBarNotification new];
    self.statusBarNotification.notificationLabelBackgroundColor = bartndrRed;
    self.statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    self.menuItems = [[NSMutableArray alloc] init];
    self.selectedMenuItems = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self.storeImageView sd_setImageWithURL:[NSURL URLWithString:@"https://scontent-b.xx.fbcdn.net/hphotos-xpf1/t31.0-8/10548074_10152372765902732_3235787422795169351_o.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder_store"]];
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
    
    [cell.itemImageView sd_setImageWithURL:[NSURL URLWithString:[menuItem image_url]] placeholderImage:[UIImage imageNamed:@"placeholder_item"]];
    
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

- (void)updateCheckOutButton
{
    NSNumber *totalNumofItems = @0;
    
    for (id key in self.selectedMenuItems) {
        NSString *itemID = (NSString *)key;
        NSNumber *quantity = [self.selectedMenuItems objectForKey:itemID];
        
        totalNumofItems = [NSNumber numberWithInt:[totalNumofItems intValue] + [quantity intValue]];
    }
    
    NSLog(@"Total Number of Items: %@", totalNumofItems);
    
    if ([totalNumofItems intValue] > 0) {
        [self.checkOutButton setTitle:[NSString stringWithFormat:@"Check Out(%@)", totalNumofItems] forState:UIControlStateNormal];
        [self showCheckOutButton];
    } else {
        [self hideCheckOutButton];
    }
}

- (void)showCheckOutButton
{
    
}

- (void)hideCheckOutButton
{
    
}

@end
