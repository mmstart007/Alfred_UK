//
//  ExpiryAndCVVSplitCellTableViewCell.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/6/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpiryAndCVVSplitCellTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *leftTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightTextField;

@end
