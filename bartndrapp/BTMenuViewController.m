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

@end

@implementation BTMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    self.menuItems = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[[[AppDelegate get] currentStore] getItems] continueWithBlock:^id(BFTask *task) {
        NSLog(@"Here");
        if (!task.error) {
            self.menuItems = (NSMutableArray *)task.result;
            NSLog(@"%@", self.menuItems);
            [self.menuTableView reloadData];
        } else {
            NSLog(@"%@", task.error);
        }
        return nil;
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    
    cell.textLabel.text = menuItem.item_name;
    cell.detailTextLabel.text = menuItem.item_description;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
