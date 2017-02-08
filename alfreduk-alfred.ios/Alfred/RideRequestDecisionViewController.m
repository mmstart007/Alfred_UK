//
//  RideRequestDecisionViewController.m
//  Alfred
//
//  Created by Arjun Busani on 02/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RideRequestDecisionViewController.h"

@interface RideRequestDecisionViewController ()

@end

@implementation RideRequestDecisionViewController
@synthesize topLayoutConstraint,bottomLayoutConstraint,leftLayoutConstraint,rightLayoutConstraint,decision,decisionTextView,isAccepted,openRatingView;

- (void)viewDidLoad {
    
    
    self.popUpView.layer.cornerRadius = 0.5;
    self.popUpView.layer.shadowOpacity = 0.8;
    self.popUpView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideRequestCancel:) name:@"didRequestForRideRequestCancel" object:nil];

  

    decisionTextView.text = decision;
    decisionTextView.textAlignment = NSTextAlignmentCenter;
    
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 ){
            topLayoutConstraint.constant = 180;
            bottomLayoutConstraint.constant = 180;
            
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            topLayoutConstraint.constant = 220;
            bottomLayoutConstraint.constant = 220;
            leftLayoutConstraint.constant = 80;
            rightLayoutConstraint.constant = 80;
            
            
        } else if ( screenHeight > 480 ){
            topLayoutConstraint.constant = 240;
            bottomLayoutConstraint.constant = 240;
            leftLayoutConstraint.constant = 80;
            rightLayoutConstraint.constant = 80;
            
            
            
        } else {
            topLayoutConstraint.constant = 150;
            bottomLayoutConstraint.constant =150;
            
            
        }
    }
    else{
            topLayoutConstraint.constant = 370;
            bottomLayoutConstraint.constant = 370;
            self.leftLayoutConstraint.constant = 240;
            self.rightLayoutConstraint.constant = 240;

    }

    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideRequestCancel" object:nil];
    
    
}
-(void)didRequestForRideRequestCancel:(NSNotification *)notification
{
    //NSArray* requestArray = [notification object];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeTheView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    NSArray* boolDecision = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:isAccepted], nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideDecisionCloseView" object:boolDecision];
    if (openRatingView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForOpenRatinView" object:nil];

    }

}
@end
