//
//  MessageBoardNewMapTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardNewMapTableViewCell.h"

@implementation MessageBoardNewMapTableViewCell
@synthesize pickupButton,dropoffButton;
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
            widFloat = 35.0f;
        } else if ( screenHeight > 480 ){
            widFloat = 35.0f;
        } else {
        }
    }
    else{
        widFloat = 410.0f;
 
    }
    
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.pickupButton.bounds.size.height+5, self.pickupButton.bounds.size.width+widFloat, 0.8f)];
    bottomLineView.backgroundColor = [UIColor grayColor];
    [self.pickupButton addSubview:bottomLineView];
    
    UIView *bottomLineView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.pickupButton.bounds.size.height+5, self.pickupButton.bounds.size.width+widFloat, 0.8f)];
    bottomLineView1.backgroundColor = [UIColor grayColor];
    [self.self.dropoffButton addSubview:bottomLineView1];

    //[self.dropoffButton addSubview:bottomLineView];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
