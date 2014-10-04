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

@interface BTMenuViewController ()

@property NSMutableDictionary *selectedMenuItems;

@end

@implementation BTMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    cell.nameLabel.text = menuItem.item_name;
    cell.descriptionLabel.text = menuItem.item_description;
    cell.priceLabel.text = [NSString stringWithFormat:@"$%@", menuItem.price];
    
    NSNumber *quantity = [self.selectedMenuItems objectForKey:[menuItem objectId]];
    
    if (quantity) {
        cell.quantityLabel.text = [NSString stringWithFormat:@"%@", quantity];
    } else {
        cell.quantityLabel.text = @"0";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.menuTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BTItem *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    
    if ([self.selectedMenuItems objectForKey:[menuItem objectId]]) {
        NSNumber *quantity = [self.selectedMenuItems objectForKey:[menuItem objectId]];
        [self.selectedMenuItems setObject:[NSNumber numberWithInt:[quantity intValue] + 1] forKey:[menuItem objectId]];
        [self.menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.selectedMenuItems setObject:[NSNumber numberWithInt:1] forKey:[menuItem objectId]];
        [self.menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
