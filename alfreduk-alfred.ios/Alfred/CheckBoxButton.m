//
//  CheckBoxButton.m
//  Alfred
//
//  Created by Arjun Busani on 21/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "CheckBoxButton.h"
@interface CheckBoxButton()

@property(nonatomic,strong)IBInspectable UIImage* checkedStateImage;
@property(nonatomic,strong)IBInspectable UIImage* uncheckedStateImage;

@end


@implementation CheckBoxButton

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self addTarget:self action:@selector(switchState) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self addTarget:self action:@selector(switchState) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self addTarget:self action:@selector(switchState) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

-(void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    
    if(isChecked)
    {
        
        [self setImage:self.checkedStateImage forState:UIControlStateNormal];
    }
    else
    {
        [self setImage:self.uncheckedStateImage forState:UIControlStateNormal];
    }
}

-(void)switchState
{
    self.isChecked = !self.isChecked;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
