//
//  WithdrawalViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/20/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//



#import "WithdrawalViewController.h"
#import "MDButton.h"
#import <Parse/Parse.h>
#import "KLCPopup/KLCPopup.h"
#import "Withdrawal/WithdrawalView.h"
#import "HUD.h"

@interface WithdrawalViewController ()<UITableViewDelegate, UITableViewDataSource, WithdrawalViewDelegate>{
    NSArray *_withdrawalsList;
    KLCPopup *_popup;
    double _pendingWithdrawalAmmount;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MDButton *addButton;

@end

@implementation WithdrawalViewController
-(void)viewDidLoad{

    [super viewDidLoad];
    _withdrawalsList =nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.addButton.imageView.image = [UIImage imageNamed:@"withdrawl"];
    
    self.title = @"Withdrawals";
    
    CGRect  frame = self.view.bounds;
    CGFloat width = 50;
    CGFloat height = 50;
    //CGFloat padding = 20;
    
    MDButton *floatingButton = [[MDButton alloc] initWithFrame:CGRectMake(frame.size.width - 20 - width, frame.size.height - 100 - height, height, height) type:MDButtonTypeFloatingAction rippleColor:[UIColor clearColor]];
    
    floatingButton.backgroundColor =  [UIColor colorWithRed:56.0f/255 green:169.0f/255 blue:180.0f/255 alpha:1.0];
    [floatingButton setImage:[UIImage imageNamed:@"withdrawal"] forState:UIControlStateNormal];
    [floatingButton addTarget:self action:@selector(requestWithdrawal:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:floatingButton];
        _pendingWithdrawalAmmount = 0;
    [self getWithdrawalsList];
}

-(void)getWithdrawalsList{

    PFQuery * query = [PFQuery queryWithClassName:@"WithdrawalRequest"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error == nil){
            _withdrawalsList = objects;
            
            [self.tableView reloadData];
            for( PFObject *request in objects){
                if([request[@"status"] isEqualToString:@"Pending"]){
                    _pendingWithdrawalAmmount += [request[@"amount"] doubleValue];
                }
            }
        }
    }];
}


#pragma mark - Table view

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *identifier = @"HistoryCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    PFObject * request = _withdrawalsList[indexPath.row];
    NSNumber * amount = request[@"amount"];
    double amountInGBP =[ amount doubleValue] /100;
    UILabel *amountLabel = [cell viewWithTag:1];
    UILabel *dateLabel =[cell viewWithTag:2];
    UILabel *statusLabel = [cell viewWithTag:3];
    
    amountLabel.text = [NSString stringWithFormat:@"£%3.2lf", amountInGBP];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM dd, yyyy"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    statusLabel.text = request[@"status"];
    dateLabel.text = [formatter stringFromDate:request[@"date"]];
    return cell;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _withdrawalsList.count;
            
}

- (IBAction)requestWithdrawal:(id)sender {
    
    NSLog(@"Withdrawal request");
    PFObject *bankInfo = [PFUser currentUser][@"BankInfo"];
    if(bankInfo == nil){
        //the user have not bank info so he cant withdrawal
        [[  [UIAlertView alloc] initWithTitle:@"Oops!" message:@"You need to enter your bank details in order to withdrawal money from your Alfred wallet.\nThis can be added in your profile.\nThe withdrawals request are processed once per week." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
    
        return;
    }
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WithdrawalView" owner:self options:nil];
    WithdrawalView * view =(WithdrawalView*) [nib objectAtIndex:0];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    view.delegate = self;
    _popup = [KLCPopup popupWithContentView:view];
    [_popup show];
}

-(void)withdrawalView:(UIView *)view didRequestWitdrawalWithAmount:(NSNumber *)amount{

    [_popup dismiss:YES];
    PFObject *withdrawallRequest = [PFObject objectWithClassName:@"WithdrawalRequest"];
    withdrawallRequest[@"user"] = [PFUser currentUser];
    double amountInCents = [amount doubleValue] * 100;
    double balanceInCents = [[PFUser currentUser][@"Balance"] doubleValue];
    double amountThatCanWithdraw = balanceInCents - _pendingWithdrawalAmmount;
    double requestedWithdrawalAmount = [amount doubleValue] * 100;
    
    if(requestedWithdrawalAmount > amountThatCanWithdraw){
       [[ [UIAlertView alloc] initWithTitle:@"Oops!" message:@"The amount that you requested exceed your current balance plus pending withdrawals" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil  , nil] show ];
    
    } else {
    
        withdrawallRequest[@"amount"] = [NSNumber numberWithDouble:amountInCents];
        withdrawallRequest[@"date"] = [NSDate dateWithTimeIntervalSinceNow:0];
        withdrawallRequest[@"status"] = @"Pending";
        
        [HUD showUIBlockingIndicatorWithText:@"Requesting"];
        [withdrawallRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [HUD hideUIBlockingIndicator];
            [self getWithdrawalsList];
            
        }];
    }
}

@end
