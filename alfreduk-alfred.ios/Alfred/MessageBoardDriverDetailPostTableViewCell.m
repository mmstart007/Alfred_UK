//
//  MessageBoardDriverDetailPostTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardDriverDetailPostTableViewCell.h"

@implementation MessageBoardDriverDetailPostTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)joinAlfredAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForJoinAlfred" object:nil];

}
@end
