//
//  ForgotPassCodeViewController.m
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "ForgotPassCodeViewController.h"
#import "ForgotPassPassTableViewController.h"
@interface ForgotPassCodeViewController ()

@end

@implementation ForgotPassCodeViewController
@synthesize submitButton, firstCodeTextField,secondCodeTextField,thirdCodeTextField,fourthCodeTextField,fifthCodeTextField,sixthCodeTextField,scrollView,email,completeCode,successData;
- (void)viewDidLoad {
    [super viewDidLoad];

    
    firstCodeTextField.delegate = self;
    secondCodeTextField.delegate = self;
    thirdCodeTextField.delegate = self;
    fourthCodeTextField.delegate = self;
    fifthCodeTextField.delegate = self;
    sixthCodeTextField.delegate = self;

  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditingTextField:) name:@"UITextFieldTextDidChangeNotification" object:firstCodeTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditingTextField:) name:@"UITextFieldTextDidChangeNotification" object:secondCodeTextField];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditingTextField:) name:@"UITextFieldTextDidChangeNotification" object:thirdCodeTextField];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditingTextField:) name:@"UITextFieldTextDidChangeNotification" object:fourthCodeTextField];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditingTextField:) name:@"UITextFieldTextDidChangeNotification" object:fifthCodeTextField];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditingTextField:) name:@"UITextFieldTextDidChangeNotification" object:sixthCodeTextField];

    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.delegate = self;



    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(cancelPage:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftButton;
}

-(void)cancelPage:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender.contentOffset.x != 0) {
        CGPoint offset = sender.contentOffset;
        offset.x = 0;
        sender.contentOffset = offset;
    }
    
}

- (void) endEditingTextField:(NSNotification *)note {
    
    id textFieldObj = (UITextField*)[note object];
    
    if (textFieldObj == firstCodeTextField && [[firstCodeTextField text] length] > 0)
    {
        
        [firstCodeTextField resignFirstResponder];
        [secondCodeTextField becomeFirstResponder];
        
    }
    
    if (textFieldObj == secondCodeTextField && [[secondCodeTextField text] length] > 0)
    {
        [secondCodeTextField resignFirstResponder];
        [thirdCodeTextField becomeFirstResponder];
    }
    
    if (textFieldObj == thirdCodeTextField && [[thirdCodeTextField text] length] > 0)
    {
        [thirdCodeTextField resignFirstResponder];
        [fourthCodeTextField becomeFirstResponder];
    }
    
    if (textFieldObj == fourthCodeTextField && [[fourthCodeTextField text] length] > 0)
    {
        [fourthCodeTextField resignFirstResponder];
        [fifthCodeTextField becomeFirstResponder];
    }
    
    if (textFieldObj == fifthCodeTextField &&[[fifthCodeTextField text] length] > 0)
    {
        [fifthCodeTextField resignFirstResponder];
        [sixthCodeTextField becomeFirstResponder];
    }
    
    if (textFieldObj == sixthCodeTextField && [[sixthCodeTextField text] length] > 0)
    {
        [sixthCodeTextField resignFirstResponder];
    }
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    if(textField == firstCodeTextField)
    {
        
        if (firstCodeTextField.text.length > 0  && range.length == 0 )
        {
            return NO;
            
        }
        
        else {

           // [firstCodeTextField setText:newString];
            //[secondCodeTextField becomeFirstResponder];
            return YES;
        }
    }
     if(textField == secondCodeTextField)
    {
        if (secondCodeTextField.text.length > 0  && range.length == 0 )
        {
            return NO;
        }else {
         //   [secondCodeTextField setText:newString];
            //[thirdCodeTextField becomeFirstResponder];
            return YES;
        }
    }
    else if(textField == thirdCodeTextField)
    {
        if (thirdCodeTextField.text.length > 0  && range.length == 0 )
        {
            return NO;
        }else {
           // [thirdCodeTextField setText:newString];
           // [fourthCodeTextField becomeFirstResponder];
            return YES;
        }
    }
    else if(textField == fourthCodeTextField)
    {
        if (fourthCodeTextField.text.length > 0  && range.length == 0 )
        {
            return NO;
        }else {
           // [fourthCodeTextField setText:newString];
           // [fifthCodeTextField becomeFirstResponder];
            return YES;
        }
    }
    else if(textField == fifthCodeTextField)
    {
        if (fifthCodeTextField.text.length > 0  && range.length == 0 )
        {
            return NO;
        }else {
            //[fifthCodeTextField setText:newString];
            //[sixthCodeTextField becomeFirstResponder];
            return YES;
        }
    }
    else if(textField == sixthCodeTextField)
    {
        if (sixthCodeTextField.text.length > 0  && range.length == 0 )
        {
            return NO;
        }else {
            //[sixthCodeTextField setText:newString];
            return YES;
        }
    }
    
    else
        return NO;
}


- (IBAction)submitCode:(id)sender {
   
    
    if (firstCodeTextField.text.length==0||secondCodeTextField.text.length==0||thirdCodeTextField.text.length==0||fourthCodeTextField.text.length==0||fifthCodeTextField.text.length==0||sixthCodeTextField.text.length==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Please enter the complete code."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else{
        
        
        
        completeCode = [NSString stringWithFormat:@"%@%@%@%@%@%@",firstCodeTextField.text,secondCodeTextField.text,thirdCodeTextField.text,fourthCodeTextField.text,fifthCodeTextField.text,sixthCodeTextField.text];
        
        
        [HUD showUIBlockingIndicatorWithText:@"Verifying.."];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:email,@"email",completeCode,@"uniqueId",nil];
            
            NSString* URL_SIGNIN = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/verifyUniqueId";
            

            [manager POST:URL_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                successData =responseObject;

                NSString* message = successData[@"message"];
                
                NSLog(@"Success: %@", successData);

                if ([message isEqualToString:@"Unique Id verified."]) {
                    [self performSegueWithIdentifier:@"CodePush" sender:self];
                    
                }
                else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:message
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    

                
                }
                
                [HUD hideUIBlockingIndicator];

                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error while sending data"
                                                                    message:@"Sorry, try again."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                NSLog(@"Error: %@", [error localizedDescription]);
                [HUD hideUIBlockingIndicator];
                

            }];
            
            

            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                
                
            });
        });
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CodePush"])
    {
        
        
        ForgotPassPassTableViewController *detailViewController = [segue destinationViewController];
        detailViewController.email = email;
        
        detailViewController.code = completeCode;
        
    }
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
