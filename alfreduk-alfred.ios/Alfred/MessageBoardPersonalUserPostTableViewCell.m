//
//  MessageBoardPersonalUserPostTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardPersonalUserPostTableViewCell.h"

@implementation MessageBoardPersonalUserPostTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editUserPost:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForEditUserPost" object:nil];

}

- (IBAction)deleteUserPost:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForDeleteUserPost" object:nil];

}
@end
