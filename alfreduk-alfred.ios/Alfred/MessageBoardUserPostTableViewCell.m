//
//  MessageBoardUserPostTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardUserPostTableViewCell.h"

@implementation MessageBoardUserPostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)beTheAlfred:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForBeTheAlfred" object:nil];

}
@end
