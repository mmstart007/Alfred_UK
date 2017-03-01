//
//  DriverCalloutNotActiveViewController.m
//  Alfred
//
//  Created by Arjun Busani on 09/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverCalloutNotActiveViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DriverCalloutNotActiveViewController ()

@end

@implementation DriverCalloutNotActiveViewController
@synthesize topLayoutConstraint,bottomLayoutConstraint,requestRideId,availbleSeats,driverID;
@synthesize driverRating,driverProfilePic,driverMobile,driverName;
@synthesize nameLabel,cellLabel,ratingLabel,picImageView;
- (void)viewDidLoad {
    [super viewDidLoad];


    self.popupView.layer.cornerRadius = 0.5;
    self.popupView.layer.shadowOpacity = 0.8;
    self.popupView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 ){
            topLayoutConstraint.constant = 100;
            bottomLayoutConstraint.constant = 100;
            
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            topLayoutConstraint.constant = 150;
            bottomLayoutConstraint.constant = 150;
            
            
            
        } else if ( screenHeight > 480 ){
            topLayoutConstraint.constant = 210;
            bottomLayoutConstraint.constant = 150;
            
            
        } else {
            topLayoutConstraint.constant = 80;
            bottomLayoutConstraint.constant =80;
            
            
       
        }
    }
    else{
        topLayoutConstraint.constant = 300;
        bottomLayoutConstraint.constant = 300;
        self.leftLayoutConstraint.constant = 200;
        self.rightLayoutConstraint.constant = 200;
        self.picLayoutConstraint.constant = 100;
    }
  
    
    [nameLabel setText:driverName];
    [cellLabel setText:driverMobile];
    [ratingLabel setText:driverRating];
    
    if (![driverProfilePic isKindOfClass:[NSNull class]]) {
        
        
        [picImageView sd_setImageWithURL:[NSURL URLWithString:driverProfilePic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    
    picImageView.layer.cornerRadius = picImageView.frame.size.height/5;
    picImageView.layer.masksToBounds = YES;
    picImageView.layer.borderWidth = 0;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)requestAlfred:(id)sender {
    
    
    NSNumber *driver = [NSNumber numberWithInt: (int)driverID];
    NSLog(@"Driver ID: %@",driver);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForInactiveDriverChosenForRide" object:@[driverID]];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)dismissAlfred:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
