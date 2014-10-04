//
//  BTTableViewCell.m
//  bartndrapp
//
//  Created by Peter Kim on 10/4/14.
//  Copyright (c) 2014 Bartndr. All rights reserved.
//

#import "BTTableViewCell.h"

@implementation BTTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.minusButton = [[UIButton alloc] initWithFrame:CGRectMake(277, 65, 34, 34)];
    [self.minusButton setImage:[UIImage imageNamed:@"minus_button"] forState:UIControlStateNormal];
    [self.minusButton addTarget:self action:@selector(handleMinusButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.minusButton];
    
    self.plusButton = [[UIButton alloc] initWithFrame:CGRectMake(277, 1, 34, 34)];
    [self.plusButton setImage:[UIImage imageNamed:@"plus_button"] forState:UIControlStateNormal];
    [self.plusButton addTarget:self action:@selector(handlePlusButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.plusButton];
    
    [self.descriptionLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)handlePlusButton:(id)sender {
    NSIndexPath *indexPath = [self.menuTableView indexPathForCell:self];
    
    if ([self.selectedMenuItems objectForKey:self.itemObjectID]) {
        NSNumber *quantity = [self.selectedMenuItems objectForKey:self.itemObjectID];
        [self.selectedMenuItems setObject:[NSNumber numberWithInt:[quantity intValue] + 1] forKey:self.itemObjectID];
        [self.menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.selectedMenuItems setObject:[NSNumber numberWithInt:1] forKey:self.itemObjectID];
        [self.menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)handleMinusButton:(id)sender {
    NSIndexPath *indexPath = [self.menuTableView indexPathForCell:self];
    
    if ([self.selectedMenuItems objectForKey:self.itemObjectID]) {
        NSNumber *quantity = [self.selectedMenuItems objectForKey:self.itemObjectID];
        if ([quantity intValue] != 0) {
            [self.selectedMenuItems setObject:[NSNumber numberWithInt:[quantity intValue] - 1] forKey:self.itemObjectID];
            [self.menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        [self.selectedMenuItems setObject:[NSNumber numberWithInt:0] forKey:self.itemObjectID];
        [self.menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
