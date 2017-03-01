//
//  MessageBoardNewTitlesTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardNewTitlesTableViewCell.h"

@implementation MessageBoardNewTitlesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    else{
        widFloat = 410.0f;

    }

    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.titleTextField.bounds.size.height+4, self.titleTextField.bounds.size.width+widFloat, 0.8f)];
    bottomLineView.backgroundColor = [UIColor grayColor];
    [self.titleTextField addSubview:bottomLineView];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
