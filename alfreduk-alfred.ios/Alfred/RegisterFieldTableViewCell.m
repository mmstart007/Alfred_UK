//
//  RegisterFieldTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RegisterFieldTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation RegisterFieldTableViewCell
@synthesize registerTextField;
- (void)awakeFromNib {
    // Initialization code
    
    CALayer *bottomBorder = [CALayer layer];

    
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 ){
            bottomBorder.frame = CGRectMake(0.0f, self.registerTextField.bounds.size.height -0.9f, self.registerTextField.bounds.size.width-30, 0.9f);

        
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            bottomBorder.frame = CGRectMake(0.0f, self.registerTextField.bounds.size.height-0.9f, self.registerTextField.bounds.size.width, 0.9f);


        
        } else if ( screenHeight > 480 ){

            bottomBorder.frame = CGRectMake(0.0f, self.registerTextField.bounds.size.height -0.9f, self.registerTextField.bounds.size.width+40, 0.9f);

        } else {
            bottomBorder.frame = CGRectMake(0.0f, self.registerTextField.bounds.size.height -0.9f, self.registerTextField.bounds.size.width-40, 0.9f);
        }
    }
    else{
        
        bottomBorder.frame = CGRectMake(0.0f, self.registerTextField.bounds.size.height -0.9f, self.registerTextField.bounds.size.width+40, 0.9f);

    }
    
    bottomBorder.backgroundColor = [UIColor blackColor].CGColor;

   [registerTextField.layer addSublayer:bottomBorder];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
