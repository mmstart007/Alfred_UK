//
//  ResendEmailViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "ResendEmailViewController.h"

@interface ResendEmailViewController ()

@end

@implementation ResendEmailViewController
@synthesize firstName,informationTextView,userid;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                    style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftButton;

    NSString *infoText = [NSString stringWithFormat:@"Hi %@, an email has been sent to your email for verification. Please check on the link given to verify your account. Your user id:%@",firstName,userid];
    
    informationTextView.text = infoText;
    [informationTextView setTextAlignment:NSTextAlignmentCenter];
    
}

-(void)cancelPage:(id)sender{
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

- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
