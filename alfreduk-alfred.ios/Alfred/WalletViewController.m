//
//  WalletViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/11/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "WalletViewController.h"
#import <Parse/Parse.h>
#import "HUD.h"
#import <QuartzCore/QuartzCore.h>
#import "SWRevealViewController/SWRevealViewController.h"
#import "KLCPopup/KLCPopup.h"
#import "AddBalanceView.h"
#import "WithdrawalViewController.h"

@interface WalletViewController(){

    double balance;
    NSMutableArray * cards;
    long defaultCardIndex;
    KLCPopup* popup ;
}

@end

@implementation WalletViewController

- (IBAction)addBalance:(id)sender {
    if( cards.count == 0){
        [[[UIAlertView alloc] initWithTitle:@"Can't upload balance" message:@"Please add a payment method" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
        return ;
    
    }
    // Show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutCenter);
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AddBalanceView" owner:self options:nil];
    AddBalanceView * view =(AddBalanceView*) [nib objectAtIndex:0];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    CGRect viewFrame = view.frame;
    viewFrame.size.width = screenWidth;
    view.frame =  viewFrame;
    view.delegate = self;
    [view setCardString:[NSString stringWithFormat:@"XXXX-XXXX-XXXX-%@",cards[defaultCardIndex][@"LastFour"]]];
    popup = [KLCPopup popupWithContentView:view
                                            showType:KLCPopupShowTypeSlideInFromBottom
                                         dismissType:KLCPopupDismissTypeSlideOutToBottom
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:NO];
    [popup showWithLayout:layout];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    cards = [[NSMutableArray alloc]init];
    defaultCardIndex = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                                          style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)] ;
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ( revealViewController ){
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self updateWallet];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#define kOFFSET_FOR_KEYBOARD 80.0
-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)addBalanceViewCanceled:(AddBalanceView*)view{

    [popup dismissPresentingPopup];
    
}

-(void)addBalanceView:(AddBalanceView*)view didAddedBalance:(double )balanceAdded{

    [popup dismissPresentingPopup];
    int amountInCents =  balanceAdded * 100;//in cents
    NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
    details[@"amount"] = [NSNumber numberWithInt:amountInCents];
    details[@"currency"] = @"gbp";
    details[@"customer"]  = [PFUser currentUser][@"stripeCustomerId"];
    details[@"card"] = cards[defaultCardIndex][@"StripeToken"]; //stripe token for card
    
    [HUD showUIBlockingIndicatorWithText:@"Please wait.."];
    [PFCloud callFunctionInBackground:@"chargeCustomer" withParameters:details block:^(id object, NSError *error)
     {
         if (!error)
         {
             NSLog(@"Added ammount to user wallet");
             balance = balance + amountInCents;
             
             [PFUser currentUser][@"Balance"] = [NSNumber numberWithLong:balance];
             [[PFUser currentUser]saveInBackground];
             [self.balanceLabel setText:[NSString stringWithFormat:@"%3.2lf", balance/100]];
             
         }
         else{
             
             NSString *errorMsg = @"Unknown error";
             errorMsg = error.userInfo[@"error"];
             
             [[[UIAlertView alloc]initWithTitle:@"Failed to add balance" message:errorMsg delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil , nil] show];
             
         }
         [HUD hideUIBlockingIndicator];
         
     }];

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 0){
    
        return 119;
    }
    else {
        return 44;
    
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    if(section == 0){
        return @"Your Alfred Balance";
    }else if(section == 2){
        
        return @"Payment methods";
    
    }else{
    
        nil;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    //int section  = indexPath.section;
    int row = (int)indexPath.row;
    
    if(indexPath.section == 0){
        
        UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BALANCE_CELL"];
        
        _balanceLabel = (UILabel*)[cell viewWithTag:1 ];
        _addBalance = (UIButton*) [cell viewWithTag:2];
        [_addBalance addTarget:self action:@selector(addBalance:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    
    }else if(indexPath.section == 1){
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PROMO_CODE_CELL"];
        return cell;
    
    }
    if(indexPath.section == 2){
        
        if(row == cards.count){
            UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"ADD_CARD_CELL"];
            return  cell;
        
        }
        
        long cardIndex = indexPath.row;
        
        PFObject * card=  cards[cardIndex];
        
        UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"CARD_CELL"];
        UILabel * cardNumberLabel = (UILabel*) [cell viewWithTag:1];
        UILabel * cardExpiryLabel = (UILabel*)[cell viewWithTag:2];
        [cardNumberLabel setText:[NSString stringWithFormat:@"Card: XXXX-XXXX-XXXX-%@",card[@"LastFour"]]];
        [ cardExpiryLabel setText:[NSString stringWithFormat:@"EXPIRY: %@", card[@"Expiry"]]];
        if(cardIndex == defaultCardIndex){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
        
    }
    else if(indexPath.section == 3){
        // withdrawal section here
        const NSString* reuseIdentifier = @"PlainCell";
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if(cell ==  nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];

        }
        cell.textLabel.text = @"Withdrawal";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    return nil;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    CGRect popupRect = popup.frame;
    
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        popupRect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
        popupRect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        popupRect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
         popupRect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    popup.frame = popupRect;
    [UIView commitAnimations];
}


-(void)updateWallet {

    balance = [[PFUser currentUser][@"Balance"] intValue];
    [self.balanceLabel setText:[NSString stringWithFormat:@"%3.2lf", balance/100.0]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Card"];
    [query whereKey:@"User" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError * error){
        if(!error){
            
            //NSLog(cardsArray);
            cards = objects;
            long index = 0;
            for(PFObject* card  in cards){
                
                if([card[@"isDefault"] boolValue]){
                    defaultCardIndex = index;
                    break;
                }
                index++;
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Failed to load user cards");
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 2){
        if(indexPath.row == cards.count){
            [self performSegueWithIdentifier:@"AddCardSegue" sender:self];
            return;
        }
        //select proper row
        if(defaultCardIndex != indexPath.row){
            cards[defaultCardIndex][@"isDefault"]= @NO;
            [cards[defaultCardIndex] saveInBackground];
            defaultCardIndex = indexPath.row ;
            cards[defaultCardIndex][@"isDefault"] = @YES;
            [cards[defaultCardIndex] saveInBackground];
            [self.tableView reloadData];
        }
    }
    
    else if(indexPath.section == 1){
        //enter promo code
        [[ [UIAlertView alloc]initWithTitle:@"Oops!" message:@"Feature not implemented yet. " delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil]show];
    
    }
    else if(indexPath.section == 3){
        UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WithdrawalViewController *controller =  [main instantiateViewControllerWithIdentifier:@"WithdrawalViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if(section == 2){
        return cards.count + 1;
    }
    return 1;

}

// Swipe to delete.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeCardFromServer:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if(indexPath.section == 1) return NO;
    if(indexPath.section == 0 )return NO;
    if(indexPath.section == 2 && indexPath.row == cards.count) return NO;
    return YES;
}

-(void)removeCardFromServer:(long)cardIndex{
    
    [HUD showUIBlockingIndicator];
    PFObject *cardToRemove = cards[cardIndex];
    [cards removeObject: cardToRemove];
    [cardToRemove deleteInBackgroundWithBlock:^(BOOL succed, NSError *error){
        if(succed){
            [self  updateWallet];
        }else{
            
        }
        [HUD hideUIBlockingIndicator];
    }];
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

