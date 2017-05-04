//
//  MessagePriceSubmitViewController.h
//  Alfred
//
//  Created by Piao on 4/26/17.
//  Copyright © 2017 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MessagePriceSubmitViewController : UIViewController

@property(strong,nonatomic)PFObject* selectedMessage;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceDecrementButton;
@property (weak, nonatomic) IBOutlet UIButton *priceIncrementButton;

@end
