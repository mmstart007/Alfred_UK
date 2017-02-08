//
//  MissingDataViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/26/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MissingDataViewController.h"
 #import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>

@implementation MissingDataViewController

-(void)viewDidLoad{

    [super viewDidLoad];
    
    NSString *profilePic = [PFUser currentUser][@"ProfilePicUrl"];
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:profilePic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.borderWidth = 2.0f;
    self.profileImageView.layer.borderColor = [UIColor clearColor].CGColor ;
    self.phoneTextField.delegate = self;
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
    

}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    [textField resignFirstResponder];
    //hide keyboard here
}

-(BOOL)validPhoneNumber:(NSString*) phoneNumber{
    
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSRegularExpression *regex = [ NSRegularExpression regularExpressionWithPattern:phoneRegex options:0 error:nil];

    NSTextCheckingResult *match = [regex firstMatchInString:phoneNumber  options:0 range:NSMakeRange(0, [phoneNumber length])];
    if(match.range.location == 0 && match.range.length == phoneNumber.length){
        return YES;
    }

    
    return NO;
}
- (IBAction)saveData:(id)sender {
    
    NSString* phoneNumber = self.phoneTextField.text;
    
    if(phoneNumber.length > 0 && [self validPhoneNumber:phoneNumber] ){
        [PFUser currentUser][@"Phone"] = phoneNumber;
        [[PFUser currentUser] saveEventually];
        [[PFUser currentUser] fetchInBackground];
        
         [self performSegueWithIdentifier:@"MainPageID" sender:self];
    
    }else{
        //animate view
        [[ [UIAlertView alloc] initWithTitle:@"Invalid phone" message:@"Please type a valid phone number and try again" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
    
    }
    
}
@end
