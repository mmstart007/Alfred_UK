//
//  AddBalanceView.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/11/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBalanceDelegate.h"




@interface AddBalanceView : UIView
- (IBAction)addBalance:(id)sender;

- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *cardTextField;
@property (nonatomic, retain) id delegate;
-(void)setCardString:(NSString*)cardString;
@end


@protocol AddBalanceDelegate

-(void)addBalanceViewCanceled:(AddBalanceView*)view;
-(void)addBalanceView:(AddBalanceView*)view didAddedBalance:(double)balance;

@end
