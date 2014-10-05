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
#import "BTTask.h"

#import "BTOrderViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface BTMenuViewController ()

@property NSMutableDictionary *selectedMenuItems;
@property NSMutableDictionary *itemObjectIDToBTItem;

@end

@implementation BTMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateStoreDetails];
    
    UIColor *bartndrRed = [UIColor colorWithRed:233.0/255.0f green:55.0/255.0f blue:41.0/255.0f alpha:1.0f];
    
    self.statusBarNotification = [CWStatusBarNotification new];
    self.statusBarNotification.notificationLabelBackgroundColor = bartndrRed;
    self.statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    self.menuItems = [[NSMutableArray alloc] init];
    self.selectedMenuItems = [[NSMutableDictionary alloc] init];
    self.itemObjectIDToBTItem = [[NSMutableDictionary alloc] init];
    
    self.checkOutButton.alpha = 0.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self updateMenuItems];
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)updateStoreDetails
{
    if ([[AppDelegate get] currentStore]) {
        [[[AppDelegate get] currentStore] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [[AppDelegate get] setCurrentStore:(BTStore *)object];
                [self setTitle:[[[[AppDelegate get] currentStore] store_name] uppercaseString]];
                [self.storeImageView sd_setImageWithURL:[NSURL URLWithString:[[[AppDelegate get] currentStore] image_url]]
                                       placeholderImage:[UIImage imageNamed:@"placeholder_store"]];
            } else {
                [self.statusBarNotification displayNotificationWithMessage:@"An error occured!" forDuration:2.5];
            }
        }];
    }
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    [self updateStoreDetails];
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
            
            // Set up itemObjectIDToBTItem
            for (BTItem *item in self.menuItems) {
                [self.itemObjectIDToBTItem setObject:item forKey:item.objectId];
            }
            
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

#pragma mark - UITableView Delegate Methods

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
    cell.BTMenuVC = self;
    
    NSNumber *quantity = [self.selectedMenuItems objectForKey:[menuItem objectId]];
    
    if (quantity) {
        cell.quantityLabel.text = [NSString stringWithFormat:@"%@", quantity];
    } else {
        cell.quantityLabel.text = @"0";
    }
    
    [cell.itemImageView sd_setImageWithURL:[NSURL URLWithString:[menuItem image_url]] placeholderImage:[UIImage imageNamed:@"placeholder_item"]];
    
    return cell;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BTOrderViewController *destination = (BTOrderViewController *)segue.destinationViewController;
    
    // clean selectedMenuItems
    for (NSString *objectID in [self.selectedMenuItems allKeys]) {
        if ([self.selectedMenuItems objectForKey:objectID] == [NSNumber numberWithInt:0]) {
            [self.selectedMenuItems removeObjectForKey:objectID];
        }
    }
    
    destination.selectedMenuItems = [self.selectedMenuItems mutableCopy];
    destination.itemObjectIDToBTItem = [self.itemObjectIDToBTItem mutableCopy];
}

#pragma mark - Check Out

- (IBAction)handleCheckOut:(id)sender {
    [self performSegueWithIdentifier:@"MenuToOrder" sender:self];
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
        [self showCheckOutButton];
        [self.checkOutButton setTitle:[NSString stringWithFormat:@"Check Out (%@)", totalNumofItems] forState:UIControlStateNormal];
    } else {
        [self hideCheckOutButton];
    }
}

- (void)showCheckOutButton
{
    [UIView animateWithDuration:0.5f delay:0.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.checkOutButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideCheckOutButton
{
    [UIView animateWithDuration:0.5f delay:0.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.checkOutButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.checkOutButton setTitle:@"Check Out" forState:UIControlStateNormal];
    }];
}

#pragma mark - Progress Bar

- (IBAction)handleProgressBarButton:(id)sender {
    [[BTTask getNumOfTasksInQueue] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            [self.statusBarNotification displayNotificationWithMessage:[NSString stringWithFormat:@"There are currently %@ drinks in line to be made!", (NSNumber *)task.result]
                                                           forDuration:2.5];
        } else {
            [self.statusBarNotification displayNotificationWithMessage:@"An error occured!" forDuration:2.5];
        }
        
        return nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
