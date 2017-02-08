//
//  MessageBoardEditMessageTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardEditMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end
