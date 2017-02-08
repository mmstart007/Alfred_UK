//
//  MessageBoardPersonalDriverPostTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardPersonalDriverPostTableViewCell.h"

@implementation MessageBoardPersonalDriverPostTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editDriverPost:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForEditDriverPost" object:nil];

}

- (IBAction)deleteDriverPost:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForDeleteDriverPost" object:nil];

}
@end
