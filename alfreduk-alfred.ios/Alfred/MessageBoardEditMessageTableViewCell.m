//
//  MessageBoardEditMessageTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardEditMessageTableViewCell.h"

@implementation MessageBoardEditMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat widFloat = 0;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 ){
            
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            widFloat = 50.0f;
        } else if ( screenHeight > 480 ){
            widFloat = 50.0f;
        } else {
        }
    }
    
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(self.messageTextView.bounds.origin.x+50.0f, self.messageTextView.bounds.size.height+10, self.messageTextView.bounds.size.width+widFloat, 0.8f)];
    bottomLineView.backgroundColor = [UIColor grayColor];
    //[self.contentView addSubview:bottomLineView];
    
    
    self.messageTextView.layer.borderWidth = 0.8f;
    self.messageTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
