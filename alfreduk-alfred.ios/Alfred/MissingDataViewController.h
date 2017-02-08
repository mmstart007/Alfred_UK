//
//  MissingDataViewController.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/26/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MissingDataViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *done;
- (IBAction)saveData:(id)sender;

@end
