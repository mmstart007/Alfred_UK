

//
//  ConfirmationViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 1/26/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "ConfirmationViewController.h"

@interface ConfirmationViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@end

@implementation ConfirmationViewController
- (IBAction)continueToMap:(id)sender {
    
    
    [self performSegueWithIdentifier:@"ShowMapSegue" sender:self];
    
    
}

@end
