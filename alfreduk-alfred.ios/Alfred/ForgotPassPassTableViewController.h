//
//  ForgotPassPassTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"

@interface ForgotPassPassTableViewController : UITableViewController<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *passwordLabel;
@property (nonatomic, strong) UITextField *retypePasswordLabel;


@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *code;

@property (strong, nonatomic) NSDictionary *successData;
@property(strong,nonatomic)NSString *validations;
@property(strong,nonatomic)UIButton* submitButton;

@end
