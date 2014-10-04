//
//  BTTableViewCell.h
//  bartndrapp
//
//  Created by Peter Kim on 10/4/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong) UIButton *minusButton;
@property (strong) UIButton *plusButton;

@property (strong) NSString *itemObjectID;

@property (strong) NSMutableDictionary *selectedMenuItems;

@property (strong) UITableView *menuTableView;

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;

- (void)handlePlusButton:(id)sender;
- (void)handleMinusButton:(id)sender;

@end
