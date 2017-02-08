//
//  MessageBoardNewLogoTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardNewLogoTableViewCell : UITableViewCell
{
    BOOL isItDriver;
    
}
@property (weak, nonatomic) IBOutlet UIButton *driverButton;
@property (weak, nonatomic) IBOutlet UIButton *userButton;

@end
