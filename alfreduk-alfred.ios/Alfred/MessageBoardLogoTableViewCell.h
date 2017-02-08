//
//  MessageBoardLogoTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardLogoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *personalButton;


@property (weak, nonatomic) IBOutlet UIButton *postAMessageButton;

- (IBAction)personalAction:(id)sender;
- (IBAction)newMessageAction:(id)sender;

@end
