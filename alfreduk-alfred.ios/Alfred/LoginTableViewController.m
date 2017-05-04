//
//  LoginTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "LoginTableViewController.h"
#import "RegisterButtonTableViewCell.h"
#import "LogoTableViewCell.h"
#import "LoginButtonTableViewCell.h"
#import "LoginFieldTableViewCell.h"
#import "LoginWithTableViewCell.h"
#import "JSONHelper.h"
#import "HUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>
#import "AlfredUser.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "RegisterPopupView.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "KLCPopup/KLCPopup.h"



@interface LoginTableViewController () <UITextFieldDelegate, RegistrationPopupProtocol>{
     KLCPopup* popup ;
    

}
@property (weak, nonatomic) IBOutlet UITextField *mailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)login:(id)sender;
- (IBAction)loginWithFacebook:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *mailImage;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImage;

@end

@implementation LoginTableViewController
@synthesize loginLabel,passwordLabel,textFieldData,successLogin,validations,submitButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.progressIndicator.hidden = YES;
    self.mailField.delegate = self;
    self.passwordField.delegate =self;

  
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRegistration" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForPassword" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(IBAction)login:(id)sender{

    NSString *email = self.mailField.text;
    NSString *pass= self.passwordField.text;
    
    if(email.length == 0 || ![self NSStringIsValidEmail:email]){
        
        [self shake:@[self.mailField, self.mailImage]];
        return;
    }
    else if(pass.length == 0){
        [self shake:@[self.passwordField, self.passwordImage]];
        return;
    }
    
    //try to log in
    self.progressIndicator.hidden = NO;
    
    [self.progressIndicator startAnimating];
    
    [PFUser logInWithUsernameInBackground:email    password:pass
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            user[@"location"] = [PFGeoPoint geoPointWithLatitude:0 longitude:0];
                                            user[@"locationAddress"] = @"Undetermined";
                                            [user saveInBackground];
                                            // Do stuff after successful login.
                                            NSLog(@"Logged in sucessfully.");
                                            PFInstallation *installation = [PFInstallation currentInstallation];
                                            installation[@"user"] = [PFUser currentUser];
                                            
                                            [installation saveInBackground];
                                            
                                            [self performSegueWithIdentifier:@"MainPagePush" sender:self];
                                            self.progressIndicator.hidden = YES;
                                            
                                            
                                        } else {
                                            
                                            if([error code] == kPFErrorConnectionFailed){
                                                
                                                NSLog(@"Error: %@ %@", error, [error userInfo]);
                                                [[[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Check your connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil , nil] show];
                                            }
                                            else if([error code] == kPFErrorDuplicateValue){
                                                //INVALID PASSWORD, LOGIN AGAIN
                                                [[[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Your password is wrong" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                                
                                                
                                            }else if([error code] == kPFErrorObjectNotFound){
                                                [[[UIAlertView alloc] initWithTitle:@"Login failed" message:@"The user is not registered" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                                
                                            }
                                            
                                            
                                            
                                            
                                            // The login failed. Check error to see why.
                                        }
                                        self.progressIndicator.hidden = YES;
                                    }];
    
    
    

    
    
}

#pragma  mark - social logins
-(IBAction)loginWithFacebook:(id)sender{
    
    NSLog(@"Log with facebook");
   
    [HUD showUIBlockingIndicator];
    [PFFacebookUtils logInWithPermissions:@[@"public_profile",@"email"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            
            NSLog(@"User signed up and logged in through Facebook!");
            
            user[@"UserMode"] = @YES;
            user[@"EnabledAsDriver"] = @NO;
            user[@"Balance"] = @0.0;
            
            user[@"location"] = [PFGeoPoint geoPointWithLatitude:0 longitude:0];
            user[@"locationAddress"] = @"Undetermined";
            
            [user saveInBackground];
            [self _loadData];

            PFObject *userRating  = [PFObject objectWithClassName:@"UserRating"];
            userRating[@"rating"]= @0.0;
            userRating[@"rideCount"] = @0;
            userRating[@"user"]= user;
            [userRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    user[@"userRating"] = userRating;
                    [user saveEventually];
                }
            }];
            PFObject *driverRating  = [PFObject objectWithClassName:@"DriverRating"];
            driverRating[@"rating"]= @0.0;
            driverRating[@"rideCount"] = @0;
            driverRating[@"user"]= user;
            [driverRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    user[@"driverRating"] = driverRating;
                    [user saveEventually];
                }
            }];

            PFInstallation *inst = [PFInstallation currentInstallation];
            //PFUser* current = [PFUser currentUser];
            inst[@"user"] = [PFUser currentUser];
            [inst saveInBackground];
            
        } else {
            NSLog(@"User logged in through Facebook!");
            
            user[@"location"] = [PFGeoPoint geoPointWithLatitude:0 longitude:0];
            user[@"locationAddress"] = @"Undetermined";
            
            [user saveInBackground];
            // [self _loadData];
            
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            
            [installation saveInBackground];
            
            [HUD showUIBlockingIndicator];
            [user fetchInBackgroundWithBlock:^(PFObject * object, NSError *error) {
                [HUD hideUIBlockingIndicator];
                
                if (error == nil) {
                    // The object has been saved.
                    [self performSegueWithIdentifier:@"MainPagePush" sender:self];

                } else {
                    // There was a problem, check error.description
                }
            }];
        }
        [HUD hideUIBlockingIndicator];
    }];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    if(textField == self.mailField && (textField.text.length == 0 || ![self NSStringIsValidEmail:textField.text])){
        [self shake:@[textField, self.mailImage]];
        return NO;
    
    }
    [textField resignFirstResponder];
    if(textField == self.mailField && self.passwordField.text.length == 0){
        [self.passwordField becomeFirstResponder];
        
    }

    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    
}

- (void)_loadData {
    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.

    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            
            PFUser* userProfile = [PFUser currentUser];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            NSString *name = userData[@"name"];
            if (name) {
                userProfile[@"FullName"] = name;
            }
            NSString *firstName = userData[@"first_name"];
            NSString *lastName = userData[@"last_name"];
            NSString *genderString = userData[@"gender"];
            if(firstName){
                userProfile[@"FirstName"] = firstName;
            }
            if(lastName){
                userProfile[@"LastName"] = lastName;
            }
            if(genderString){
                userProfile[@"Female"] = genderString;
            }
            
            NSString *email = userData[@"email"];
            if(email){
                userProfile[@"email"] = email;
            }
            userProfile[@"ProfilePicUrl"] =  [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            [userProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self performSegueWithIdentifier:@"MainPagePush" sender:self];
            }];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)register:(id)sender {
    
    // Show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutCenter);
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RegistrationPopup" owner:self options:nil];
    RegisterPopupView * view =(RegisterPopupView*) [nib objectAtIndex:0];
    view.delegate = self;
    [view sizeToFit];
  
    [view.closeButton addTarget:popup action:@selector(dismissPresentingPopup)  forControlEvents:UIControlEventTouchUpInside];
    popup = [KLCPopup popupWithContentView:view
                                  showType:KLCPopupShowTypeBounceInFromLeft
                               dismissType:KLCPopupDismissTypeBounceOutToRight
                                  maskType:KLCPopupMaskTypeDimmed
                  dismissOnBackgroundTouch:NO
                     dismissOnContentTouch:NO];
    [popup showWithLayout:layout];
}

-(void)registrationSucessfullWithId:(NSString *)id{

    [popup dismissPresentingPopup];
    [self performSegueWithIdentifier:@"MainPagePush" sender:self];
}


@end
