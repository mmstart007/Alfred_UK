//
//  RegisterPopupView.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/14/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "RegisterPopupView.h"
#import <Parse/Parse.h>

@implementation RegisterPopupView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.errorLabel setText:@""];
    self.activityIndicator.hidden = YES;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.checkBox.checked= NO;
    
    [self.checkBox addTarget:self action:@selector(checkboxDidChange:) forControlEvents:UIControlEventValueChanged];
    self.checkBox.textLabel.text = @"";
  
    
}

- (void)checkboxDidChange:(CTCheckbox *)checkbox
{
    NSLog(@"%d", checkbox.checked);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)register:(id)sender {
    
    if(self.firstName.text.length ==0  || self.lastNameField.text.length ==0){
    
        [self shake:@[self.firstName, self.lastNameField, self.nameContainer] ];
        [self.errorLabel setText:(self.firstName.text.length == 0)?(@"First name is required."):(@"Last name is required.") ];
        return;
    
    }else if(self.emailField.text.length ==0){
        [self shake:@[self.emailField]];
        [self.errorLabel setText:@"Email is required."];
        return;
    }else if(![self NSStringIsValidEmail:self.emailField.text]){
        [self shake:@[self.emailField]];
        [self.errorLabel setText:@"This is not a valid email address"];
        return;
    }
    else if(self.passwordField.text.length == 0){
        [self.errorLabel setText:@"Please type a password."];
        [self shake:@[self.passwordField]];
        return;
        
    }else if( self.passwordField.text.length < 4){
        [self.errorLabel setText:@"Password must be at least 4 digits."];
        [self shake:@[self.passwordField]];
        
        return;
    }else if(self.passwordField.text.length > 0 && ![self.retypePasswordField.text isEqualToString:self.passwordField.text]){
        [self.errorLabel setText:@"Password must match."];
        [self shake:@[self.retypePasswordField]];
        
    }else if(!self.checkBox.checked){
        
        [self.errorLabel setText:@"Must agree the Terms and Conditons."];
        
        [self shake:@[self.checkBox]];
    //check terms and conditions accepted
        return;
    }
    //register here
    
    [self performRegistration];
    
    
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void)performRegistration {

    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    PFUser *user = [PFUser user];
    user.username = self.emailField.text;
    
    user.password = self.passwordField.text;
    user.email = self.emailField.text;
    user[@"FullName"] =   [NSString stringWithFormat:@"%@ %@",
                           [self.firstName.text capitalizedString],
                           [self.lastNameField.text capitalizedString]];
    
    user[@"FirstName"] = self.firstName.text;
    user[@"LastName"] = self.lastNameField.text;
    
    
    // other fields can be set just like with PFObject
    user[@"Phone"] = @"+44 - ";
    user[@"PromoCode"] = @1234;
    user[@"UserMode"] = @NO;
    user[@"EnabledAsDriver"] = @NO;
    user[@"Balance"] = @0.0;
    user[@"email"] = self.emailField.text;
    user[@"location"] = [PFGeoPoint geoPointWithLatitude:0 longitude:0];
    user[@"driverRating"] = @0.0;
    user[@"driverRideCount"] = @0;
    user[@"driverCancelRideCount"] = @0;
    user[@"passengerRating"] = @0.0;
    user[@"passengerRideCount"] = @0;
    user[@"passengerCancelRideCount"] = @0;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {   // Hooray! Let them use the app now.
            //generate wallet
            
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackground];
            
            [self.delegate registrationSucessfullWithId:self.emailField.text];
            
        } else {
            
            if([error code] == kPFErrorUsernameTaken){
                [[[UIAlertView alloc] initWithTitle:@"Registration failed" message:@"Email is already in use, try another mail or log in" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil]show ];
                
            }
            else if([error code] == kPFErrorConnectionFailed){
                
                [[[UIAlertView alloc] initWithTitle:@"Registration failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                
            }
            //NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
            
        }
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;

    }];
    
    



}
- (void) shake:(NSArray*)views {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    for(UIView * view in views){
        [view.layer addAnimation:animation forKey:@"shake"];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self endEditing:YES];
    
}




@end
