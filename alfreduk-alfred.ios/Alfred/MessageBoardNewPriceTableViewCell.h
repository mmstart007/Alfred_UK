//
//  MessageBoardNewPriceTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardNewPriceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

- (IBAction)changePrice:(id)sender;

@end
