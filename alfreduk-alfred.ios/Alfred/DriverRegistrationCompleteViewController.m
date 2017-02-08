//
//  DriverRegistrationCompleteViewController.m
//  Alfred
//
//  Created by Arjun Busani on 21/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverRegistrationCompleteViewController.h"

@interface DriverRegistrationCompleteViewController ()

@end

@implementation DriverRegistrationCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(cancelPage:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftButton;
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

@end
