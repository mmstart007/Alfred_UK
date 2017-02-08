//
//  ResendEmailViewController.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResendEmailViewController : UIViewController

@property(strong,nonatomic)NSString *firstName;
@property(strong,nonatomic)NSString *userid;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeView:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *informationTextView;

@end
