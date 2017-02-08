//
//  RegisterPopupView.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/14/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTCheckbox.h"

@interface RegisterPopupView : UIView <UITextFieldDelegate>

@property (weak,nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *nameContainer;

@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *retypePasswordField;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet CTCheckbox *checkBox;

@end


@protocol RegistrationPopupProtocol <NSObject>

-(void)registrationSucessfullWithId:(NSString*)id;
@end
