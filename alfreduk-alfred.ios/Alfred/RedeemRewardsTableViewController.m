//
//  RedeemRewardsTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RedeemRewardsTableViewController.h"
#import "SWRevealViewController.h"

#import "MyWalletHeadingTableViewCell.h"
#import "RedeemBottomTableViewCell.h"
#import "MyWalletBalanceTableViewCell.h"
#import "RedeemCouponTableViewCell.h"
#import "HUD.h"
#import <Parse/Parse.h>

@interface RedeemRewardsTableViewController ()<SWRevealViewControllerDelegate>

@end

@implementation RedeemRewardsTableViewController
@synthesize promoCodeTextField;


- (void)hideNavigationBar {
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    balance = [[PFUser currentUser][@"Balance"] intValue];

    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:
                                   [UIImage imageNamed:@"BackgroundImage"]];
    
    UIImage *image1 = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:image1
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForEnterPromoCode:) name:@"didRequestForEnterPromoCode" object:nil];

    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = @"REDEEM REWARDS";
    //[self hideNavigationBar];
    
    
    if ( revealViewController ){
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        
        
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForEnterPromoCode" object:nil];
    
}
- (void) didRequestForEnterPromoCode:(NSNotification *)notification
{   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Promo Code" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil] ;
    alertView.tag = 1;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1) {
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        NSLog(@"alerttextfiled - %@",alertTextField.text);
        
        if ([alertTextField.text isEqualToString:@""]) {
            [self invalidEntry];
        }
        else{
            [self addPromoCode:alertTextField.text];
        }

    }
    
    
}


-(void)invalidEntry{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Promo Code" message:@"Invalid entry" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] ;
    alertView.tag = 1;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}


-(void)addPromoCode:(NSString*)promoCode{
    [HUD showUIBlockingIndicatorWithText:@"Validating.."];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *tokenID = [prefs stringForKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        //[manager.requestSerializer setValue:tokenID forHTTPHeaderField:@"tokenId"];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:promoCode,@"promoCode",tokenID,@"userId",nil];
        
        
        NSString* URL_SIGNIN = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/addPromoCode";
        
        [manager POST:URL_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success: %@", responseObject);
            NSString* message = responseObject[@"message"];
            if ([message isEqualToString:@"10.0 amount added to wallet"]) {
                [self getUserWallet:tokenID];
            }
            
            else if ([message isEqualToString:@"User can add promo code of another Alfred user only once."]){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"User can add promo code of another Alfred user only once."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                

            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Invalid Promo Code."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];

            }
            [HUD hideUIBlockingIndicator];

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            [HUD hideUIBlockingIndicator];

        }];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
        });
    });
    
    
}

-(void)getUserWallet:(NSString*)tokenID{
    [HUD showUIBlockingIndicatorWithText:@"Updating Wallet.."];
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:tokenID forHTTPHeaderField:@"tokenId"];
        
        
        [manager GET:@"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/getUserWalletData"
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"JSON: %@", responseObject);
                 
                 
                 NSArray* cards = responseObject[@"cards"];
                 int balanceInt = [responseObject[@"balance"] intValue];
                 
                 
                 
                 NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                 [prefs setObject:cards forKey:@"cards"];
                 [prefs setValue:[NSNumber numberWithInt:balanceInt] forKey:@"balance"];
                 
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [self.tableView reloadData];

                 [HUD hideUIBlockingIndicator];
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                     message:@"£10.0 amount added to wallet."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
                 alertView.tag =3;
                 [alertView show];
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
                 [HUD hideUIBlockingIndicator];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error while sending data"
                                                                     message:@"Sorry, try again."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 
                 NSLog(@"Error: %@", [error localizedDescription]);
                 
                 
                 
                 
             }];
        
        
        
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self.tableView reloadData];

        });
    });
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        return 2;
    }
    else if (section==1){
        return 1;
    }
    else if (section==2){
        return 1;
    }
    else if (section==3){
        return 1;
    }

    
    else
        return 2;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"ProfilePicTableViewCell";
    UITableViewCell *cell;
  
    

 
    
    if ([indexPath section]==1) {
        static NSString *simpleTableIdentifier = @"MyWalletHeadingTableViewCell";
        MyWalletHeadingTableViewCell *cell = (MyWalletHeadingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyWalletHeadingTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.headingLabel.text = @"ACCOUNT BALANCE";
        return cell;
    }
    
    if ([indexPath section]==2) {
        static NSString *simpleTableIdentifier = @"MyWalletBalanceTableViewCell";
        MyWalletBalanceTableViewCell *cell = (MyWalletBalanceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyWalletBalanceTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];

       
        
        NSString* balanceStr = [NSString stringWithFormat:@"£%ld",(long)balance];
        [cell.balanceLabel setText:balanceStr];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if ([indexPath section]==3) {
        static NSString *simpleTableIdentifier = @"RedeemCouponTableViewCell";
        RedeemCouponTableViewCell *cell = (RedeemCouponTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RedeemCouponTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];

        
       
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    if ([indexPath section]==4) {
        static NSString *simpleTableIdentifier = @"RedeemBottomTableViewCell";
        RedeemBottomTableViewCell *cell = (RedeemBottomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RedeemBottomTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        
        if (indexPath.row==1) {
            cell.bgImageView.hidden = YES;

            cell.redeemButton.hidden = YES;
        }
        return cell;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section]==0) {
        if (indexPath.row==0) {
            
            
            if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
                
                CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
                CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
                if( screenHeight < screenWidth ){
                    screenHeight = screenWidth;
                }
                
                if( screenHeight > 480 && screenHeight < 667 ){
                    return 20;
                    
                    
                } else if ( screenHeight > 480 && screenHeight < 736 ){
                    return 20;
                    
                } else if ( screenHeight > 480 ){
                    return 20;
                    
                } else {
                    return 20;
                    
                }
            }
        }
        else
            return 130;
        
    }
    else if ([indexPath section]==1) {
        return 35;
    }
    
    else if ([indexPath section]==2) {
        return 35;
    }
    else if ([indexPath section]==3) {
        return 80;
    }
    
    else if ([indexPath section]==4) {
        
        if (indexPath.row==0) {
            return 85;
        }
        else{
            return 50;
        }
    }
    return 45;
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
