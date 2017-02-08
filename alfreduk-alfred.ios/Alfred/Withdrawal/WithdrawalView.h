//
//  WithdrawalView.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/20/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WithdrawalViewDelegate <NSObject>

-(void)withdrawalView:(UIView*) view didRequestWitdrawalWithAmount:(NSNumber*)ammount;

@end

@interface WithdrawalView : UIView
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property id delegate;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;

@end
