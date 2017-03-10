//
//  MessageBoardLogoTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardLogoTableViewCell.h"

@implementation MessageBoardLogoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)personalAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForPersonalMessages" object:nil];

}

- (IBAction)newMessageAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForNewMessageBoard" object:nil];

}
@end
