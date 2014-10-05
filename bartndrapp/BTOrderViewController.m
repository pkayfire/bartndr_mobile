//
//  BTOrderViewController.m
//  bartndrapp
//
//  Created by Peter Kim on 10/4/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTOrderViewController.h"

#import "BTOrderTableViewCell.h"
#import "AppDelegate.h"

#import "BTItem.h"

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface BTOrderViewController ()

@property NSMutableArray *menuItems;

@end

@implementation BTOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateStoreDetails];
    
    self.menuItemsTableView.delegate = self;
    self.menuItemsTableView.dataSource = self;
    
    self.menuItems = [[NSMutableArray alloc] init];
    
    UIColor *bartndrRed = [UIColor colorWithRed:233.0/255.0f green:55.0/255.0f blue:41.0/255.0f alpha:1.0f];

    self.statusBarNotification = [CWStatusBarNotification new];
    self.statusBarNotification.notificationLabelBackgroundColor = bartndrRed;
    self.statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];
    
    NSNumber *totalPrice = 0;
    for (NSString *objectID in [self.selectedMenuItems allKeys]) {
        
        NSNumber *itemPrice = [(BTItem *)[self.itemObjectIDToBTItem objectForKey:objectID] price];
        NSNumber *quantity = [self.selectedMenuItems objectForKey:objectID];
        
        NSNumber *price = [NSNumber numberWithInt:[itemPrice intValue] * [quantity intValue]];
        
        totalPrice = [NSNumber numberWithInt:[totalPrice intValue] + [price intValue]];
        
        [self.menuItems addObject:objectID];
    }
    
    self.totalPrice.text = [NSString stringWithFormat:@"$%@", totalPrice];
    [self.placeOrderButton setTitle:[NSString stringWithFormat:@"Place Order ($%@)", totalPrice] forState:UIControlStateNormal];
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
    return [[self.selectedMenuItems allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BTTableViewCell";
    BTOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[BTOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *objectID = [self.menuItems objectAtIndex:indexPath.row];
    BTItem *menuItem = [self.itemObjectIDToBTItem objectForKey:objectID];
    NSNumber *quantity = [self.selectedMenuItems objectForKey:objectID];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.text = menuItem.item_name;
    cell.quantityLabel.text = [NSString stringWithFormat:@"Quantity: %@", [quantity stringValue]];
    cell.priceLabel.text = [NSString stringWithFormat:@"$%@", menuItem.price];
    
    NSNumber *subTotal = [NSNumber numberWithInt:[menuItem.price intValue] * [quantity intValue]];
    cell.subtotalPriceLabel.text = [NSString stringWithFormat:@"$%@", [subTotal stringValue]];
    
    [cell.itemImageView sd_setImageWithURL:[NSURL URLWithString:[menuItem image_url]] placeholderImage:[UIImage imageNamed:@"placeholder_item"]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePlaceOrderButton:(id)sender {
    AppDelegate *appDelegate = [AppDelegate get];
    
    if (appDelegate.braintreeClientToken) {
        Braintree *braintree = [Braintree braintreeWithClientToken:appDelegate.braintreeClientToken];
        self.braintreeVC = [braintree dropInViewControllerWithDelegate:self];
        
        self.braintreeVC.view.tintColor = [UIColor colorWithRed:233.0/255.0f green:55.0/255.0f blue:41.0/255.0f alpha:1.0f];
        self.braintreeVC.summaryTitle = @"Your Bartndr Order";
        self.braintreeVC.summaryDescription = @"Yours drinks are almost ready!";
        self.braintreeVC.displayAmount = self.totalPrice.text;
        self.braintreeVC.callToActionText = @"Pay Now";
        
        self.braintreeVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                              target:self
                                                                                                              action:@selector(userDidCancelPayment)];
        self.braintreeVC.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:233.0/255.0f green:55.0/255.0f blue:41.0/255.0f alpha:1.0f];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.braintreeVC];
        
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    } else {
        [self.placeOrderButton setUserInteractionEnabled:NO];

    }
}

- (void)userDidCancelPayment {
    [self.braintreeVC dismissViewControllerAnimated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.statusBarNotification displayNotificationWithMessage:@"Placing Order..." completion:nil];
    });
    
    [[BTItem processItems:[self.selectedMenuItems mutableCopy]] continueWithBlock:^id(BFTask *task) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.statusBarNotification dismissNotification];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.BTMenuVC clearSelectedMenuItems];
            [self.navigationController popViewControllerAnimated:YES];
            [self.statusBarNotification displayNotificationWithMessage:@"Order has been placed!" forDuration:2.5];
        });
        
        return nil;
    }];
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [viewController dismissViewControllerAnimated:YES completion:^{
        [self.placeOrderButton setUserInteractionEnabled:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.statusBarNotification displayNotificationWithMessage:@"Placing Order..." completion:nil];
        });
        
        [[BTItem processItems:[self.selectedMenuItems mutableCopy]] continueWithBlock:^id(BFTask *task) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.statusBarNotification dismissNotification];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.BTMenuVC clearSelectedMenuItems];
                [self.navigationController popViewControllerAnimated:YES];
                [self.statusBarNotification displayNotificationWithMessage:@"Order has been placed!" forDuration:2.5];
            });
            
            return nil;
        }];
    }];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
