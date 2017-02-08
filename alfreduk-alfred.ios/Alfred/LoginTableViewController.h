//
//  LoginTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

@interface LoginTableViewController : UIViewController
@property (nonatomic, strong) UITextField *loginLabel;
@property (nonatomic, strong) UITextField *passwordLabel;

@property (retain, nonatomic) NSMutableArray *textFieldData;
@property (strong, nonatomic) NSDictionary *successLogin;

@property(strong,nonatomic)UIButton* submitButton;

@property(strong,nonatomic)NSString *validations;
- (IBAction)register:(id)sender;


@end
