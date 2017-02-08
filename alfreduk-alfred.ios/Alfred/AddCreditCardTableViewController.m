    //
//  AddCreditCardTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AddCreditCardTableViewController.h"
#import "MyWalletRedeemBottomTableViewCell.h"
#import "MyWalletRedeemBottomTableViewCell.h"

#import "MyWalletHeadingTableViewCell.h"
#import "AddCardCardDetailsTableViewCell.h"
#import "AddCardDetailsSplitTableViewCell.h"
#import "ExpiryAndCVVSplitCellTableViewCell.h"
#import "AddCardDetailsTableViewCell.h"
#import "SWRevealViewController.h"
#import "HUD.h"
#import "Stripe.h"

#import "Parse/Parse.h"

#import "TWMessageBarManager.h"



@interface AddCreditCardTableViewController ()<UITextFieldDelegate>{




    STPCard *card;
}
@property (weak, nonatomic) IBOutlet UIView *cardNumberView;

@property (weak, nonatomic) IBOutlet UITextField *cardTextField;
@property (weak, nonatomic) IBOutlet UIView *expiryView;
@property (weak, nonatomic) IBOutlet UITableViewCell *cvvView;
@property (weak, nonatomic) IBOutlet UITextField *zipView;

@property (weak, nonatomic) IBOutlet UITextField *expiryTextField;
@property (weak, nonatomic) IBOutlet UITextField *cvvTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation AddCreditCardTableViewController

- (void)viewDidLoad {
    
    
    UIEdgeInsets inset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    
    self.expiryTextField.delegate = self;
    self.cardTextField.delegate = self;
    self.cvvTextField.delegate = self;
    
    [self.errorLabel setText:@""];
    card = [[STPCard alloc] init];
    
    
  

  
                                   
  

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target: self action:@selector(dimissAddNewCard)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    
    
   
    [self.cardTextField becomeFirstResponder];
    

    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if(textField == self.cardTextField){
            //card code
        
        // All digits entered
        if (range.location == 19) {
            return NO;
        }
        
        // Reject appending non-digit characters
        if (range.length == 0 &&
            ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
        
        // Auto-add hyphen before appending 4rd or 7th digit
        if (range.length == 0 &&
            (range.location == 4 || range.location == 9  || range.location == 14 )) {
            textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
            return NO;
        }
        
        // Delete hyphen when deleting its trailing digit
        if (range.length == 1 &&
            (range.location == 5 || range.location == 10 || range.location == 15))  {
            range.location--;
            range.length = 2;
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }

        
        
    }
    if(textField == self.cvvTextField){
        
        
        //cvv code
        
        if(range.location == 3){
            return NO;
        }

    }
    if(textField == self.expiryTextField){
        //expiry text field
        if (range.location == 5){
            return  NO; // no more than 5 characters
        }
        if(range.length == 0 && range.location == 2){
            textField.text = [NSString stringWithFormat:@"%@/%@", textField.text, string];
            return NO;
        }
        // Delete hyphen when deleting its trailing digit
        if (range.length == 1 &&
            (range.location == 3 ))  {
            range.location--;
            range.length = 2;
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }

    }
    else{
        // zip code text field
        // Reject appending non-digit characters
        if (range.length == 0 &&
            ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
        if (range.location == 9 && range.length == 0){
            return NO;
        }
    
    }
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}

- (void) shake:(UIView*)view {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    
    [view.layer addAnimation:animation forKey:@"shake"];
    
}

-(void)save{
    
    
    [self.errorLabel setText:@""];
    NSLog(@"Adding card");
    //check field details
    NSLog(self.cvvTextField.text);
    
    [self.cardTextField resignFirstResponder];
    [self.expiryTextField resignFirstResponder];
    [self.cvvTextField resignFirstResponder];
    [self.zipCodeTextField resignFirstResponder];

    
    if(self.cardTextField.text.length == 0){
        [self.errorLabel setText:@"Card number is required."];
        [self shake:self.cardNumberView];
        return;
    
    }else if(self.expiryTextField.text.length ==0){
        [self.errorLabel setText:@"Expiration date is required."];
            [self shake:self.expiryView];
        return;
    }else if(self.cvvTextField.text.length == 0){
        [self.errorLabel setText:@"CVV is required."];
                [self shake:self.cvvView];
        return;
        
    }else if(self.zipCodeTextField.text.length==0){
        [self.errorLabel setText:@"ZIP code is required."];
                [self shake:self.zipView];
    
        return;
    }
    
    [HUD showUIBlockingIndicatorWithText:@"Adding Card..."];
   
    
    
    
    card.number = self.cardTextField.text ;
    NSLog([NSString stringWithFormat:@"Card Number: %@",self.cardTextField.text ]);
    
    NSString *expiry = self.expiryTextField.text;
    NSScanner *scanner = [NSScanner scannerWithString:expiry];
    NSInteger month;
    [scanner scanInteger:&month];
    NSInteger year ;
    [scanner scanString:@"/" intoString:nil];
    [scanner scanInteger:&year];
    NSLog([NSString stringWithFormat:@"Expiry: %2ld/%2ld",(long)month,(long)year]);
    
    card.expMonth = month;
    card.expYear = year;
    card.cvc = self.cvvTextField.text;
    
    NSLog([NSString stringWithFormat:@"CVV: %@",self.cvvTextField.text]);
    
    
    //genera un token con el nuevo card y lo guarda
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
       
        if (error) {
            NSLog(@"Error in card");
            
            NSString *errorMessage = error.localizedDescription;
            [self.errorLabel setText:errorMessage];
            [HUD hideUIBlockingIndicator];
        } else {
            
            
            //add card to customer, pues este ya existe
            
            if([PFUser currentUser][@"stripeCustomerId"] != nil){
                
                [self addCardToCustomer:(NSString *)token.tokenId];
                
            }
            else{
                
                //no existe customer, lo creo por primera vez
                [self createCustomer:(NSString *)token.tokenId completion:^(id object, NSError * error){
                    [HUD hideUIBlockingIndicator];

                    if(!error){
                        NSLog(@"Succeeded");
                        
                        [PFUser currentUser][@"stripeCustomerId"] = object[@"id"];
                        [[PFUser currentUser] saveInBackground];
                        
                        [self addCardToCustomer:token.tokenId];
                    }else{
                    
                        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Ooops! "
                                                                       description:@"Can't add the card to your wallet"
                                                                              type:TWMessageBarMessageTypeError];
                        NSLog(error.localizedDescription);
                    }
                    
                }];
            }
        }
    }];
    
    
  
}


-(void) addCardToCustomer:(NSString*)tokenId{

    NSString *customerId = [PFUser  currentUser][@"stripeCustomerId"];
    assert(customerId!=NULL);
    
    [PFCloud callFunctionInBackground:@"stripeAddCardToCustomer"
                       withParameters:@{
                                        @"tokenId":tokenId,
                                        @"customerId": customerId
                                        }
                                block:^(id object, NSError *error) {
                                    
                                    [HUD hideUIBlockingIndicator];
                                    //Object is an NSDictionary that contains the stripe customer information, you can use this as is, or create an instance of your own customer class
                                    
                                    
                                    //save data for user wallet in parse
                                    PFObject *cardObject =[PFObject objectWithClassName:@"Card"];
                                    NSArray *items = [(NSString*)object componentsSeparatedByString:@"\""];
                                    
                                    
                                    
                                    cardObject[@"User"]= [PFUser currentUser];
                                    cardObject[@"LastFour"] = card.last4;
                                    cardObject[@"Expiry"] = [NSString stringWithFormat:@"%2lu/%2lu",(unsigned long)card.expMonth,(unsigned long) card.expYear];
                                    cardObject[@"StripeToken"] = items[3];
                                    [cardObject saveInBackground];
                                    
                                    // [self dismissViewControllerAnimated:YES completion:nil];
                                   [self.navigationController popViewControllerAnimated:YES];
                                    
                                }];


}


-(void)createCustomer:(NSString *)token completion:(PFIdResultBlock)handler
{
    
    
    NSString * email= [PFUser currentUser][@"Email"];
    NSString * fullName =[PFUser currentUser][@"FullName"];
    NSString * objectId = [PFUser currentUser].objectId;
    
    
    [PFCloud callFunctionInBackground:@"createCustomer"
                       withParameters:@{
                                        @"email": [PFUser currentUser][@"Email"],
                                        @"name": [PFUser currentUser][@"FullName"],
                                        @"objectId":[[PFUser currentUser] objectId]
                                        }
                                block:^(id object, NSError *error) {
                                    
                                    //Object is an NSDictionary that contains the stripe customer information, you can use this as is, or create an instance of your own customer class
                                    handler(object,error);
                                }];
}



//cancel adding a new card
-(void)dimissAddNewCard{
   [self.navigationController popViewControllerAnimated:YES];
}



@end
