//
//  AboutViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/15/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AboutViewController.h"

#import "SWRevealViewController/SWRevealViewController.h"
@interface AboutViewController ()


@end

@implementation AboutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"About";
    
    
    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    
   
    
    
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    
    
    
    // [self hideNavigationController];
    
    
    
    if ( revealViewController ){
        
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        
        
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        

        
    }
    
    
    // Do any additional setup after loading the view.
    
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
