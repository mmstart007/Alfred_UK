//
//  RideSettingsViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 9/23/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "RideSettingsViewController.h"
#import "HUD.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kOFFSET_FOR_KEYBOARD 80.0

@interface RideSettingsViewController (){
    CGSize keyboardSize;
    int seats;
    double pricePerSeat;
    BOOL isLadies;
}
@property (weak, nonatomic) IBOutlet UIView *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *decreaseBtn;
@property (weak, nonatomic) IBOutlet UIButton *increaseSeatsBtn;
@property (weak, nonatomic) IBOutlet UIButton *decreasePriceBtn;
@property (weak, nonatomic) IBOutlet UIButton *increasePriceBtn;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end


@implementation RideSettingsViewController
@synthesize destination, destinationAddress;

- (IBAction)increaseSeats:(id)sender {
    
    seats = seats + 1;
    if(seats == 6){
        
        self.increaseSeatsBtn.enabled = false;
        
    }
    self.seatsLabel.text = [NSString stringWithFormat:@"%d", seats];
    self.decreaseBtn.enabled = YES;
    
    
}

- (IBAction)decreaseSeats:(id)sender {
    seats = seats -1;
    if(seats == 1){
        self.decreaseBtn.enabled = NO;
    }
    self.seatsLabel.text = [NSString stringWithFormat:@"%d", seats];
    self.increaseSeatsBtn.enabled = YES;
}

- (IBAction)increasePrice:(id)sender {
    
    pricePerSeat = pricePerSeat + 2;
    if(pricePerSeat == 50){
        
        self.increasePriceBtn.enabled = false;
        
    }
    self.priceLabel.text = [NSString stringWithFormat:@"%5.2lf", pricePerSeat];
    self.decreasePriceBtn.enabled = YES;
    
    
    
}

- (IBAction)decreasePrice:(id)sender {
    
    pricePerSeat = pricePerSeat - 2;
    if(pricePerSeat == 2){
        
        self.decreasePriceBtn.enabled = false;
        
    }
    self.priceLabel.text = [NSString stringWithFormat:@"%5.2lf", pricePerSeat];
    self.increasePriceBtn.enabled = YES;
    
    
}

- (IBAction)ladiesTouchUpInside:(id)sender {
    if([sender isOn]){
        isLadies = YES;
        NSLog(@"Switch is ON");
    } else{
        isLadies = NO;
        NSLog(@"Switch is OFF");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    self.decreasePriceBtn.enabled = NO;
    self.decreaseBtn.enabled = NO;
    seats = 1;
    pricePerSeat = 2.00;
    isLadies = NO;
    
    self.title = @"Configure ride";
    
    
}

-(void) viewWillDisappear:(BOOL)animated{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    
}

-(void)keyboardWillShow:(NSNotification*)notification {
    
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self setViewMovedUp:YES];
    
    
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) shake:(UIView*)view {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    [view.layer addAnimation:animation forKey:@"shake"];
    
}

- (IBAction)saveRideData:(id)sender {
    
    [HUD showUIBlockingIndicatorWithText:@"Saving.."];
    [PFCloud callFunctionInBackground:@"CreateDriverPathway"
                       withParameters:@{@"destination": destination,
                                        @"destinationAddress": destinationAddress,
                                        @"numberOfSeats": [NSNumber numberWithInt: seats],
                                        @"pricePerSeat": [NSNumber numberWithInt: pricePerSeat * 100],
                                        @"ladiesOnly": [NSNumber numberWithBool: isLadies]}
                                block:^(PFObject *object, NSError *error) {
                                    [ HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        NSLog(@"Driver data updated sucessfully");
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"didConfigureRide"
                                                                                            object:nil
                                                                                          userInfo:@{@"driverPathwayObject": object,}];
                                        [self.navigationController popViewControllerAnimated:YES];
                                    } else {
                                        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Sorry, can save the ride settings, please try again" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                        NSLog(@"failed");
                                    }
                                }];
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
