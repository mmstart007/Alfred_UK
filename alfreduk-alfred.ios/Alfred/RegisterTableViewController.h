//
//  RegisterTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
@interface RegisterTableViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *firstNameLabel;
@property (nonatomic, strong) UITextField *lastNameLabel;
@property (nonatomic, strong) UITextField *phoneLabel;
@property (nonatomic, strong) UITextField *emailLabel;
@property (nonatomic, strong) UITextField *passwordLabel;
@property (nonatomic, strong) UITextField *retypePasswordLabel;

@property (retain, nonatomic) NSMutableArray *textFieldData;

@property (strong, nonatomic) NSDictionary *successRegistration;
@property(strong,nonatomic)NSString *validations;
@property(strong,nonatomic)UIButton* submitButton;

@property(strong,nonatomic)NSString *useridForNext;

@end
