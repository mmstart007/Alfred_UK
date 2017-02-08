//
//  ForgotPassCodeViewController.h
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"

@interface ForgotPassCodeViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *firstCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *fourthCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *fifthCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *sixthCodeTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *completeCode;
- (IBAction)submitCode:(id)sender;

@property (strong, nonatomic) NSDictionary *successData;

@end


