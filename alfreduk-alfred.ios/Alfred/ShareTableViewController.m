//
//  ShareTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "ShareTableViewController.h"
#import "SWRevealViewController.h"

#import <Parse/Parse.h>







@interface ShareTableViewController ()<SWRevealViewControllerDelegate,UITableViewDelegate,UIActionSheetDelegate>{

    
    NSString *_promoCode;
    UIActionSheet *_shareActionSheet;
}

@end

@implementation ShareTableViewController

- (void)viewDidLoad {

    
    [super viewDidLoad];
   
        self.tableView.delegate = self;
//    promoCode = [prefs valueForKey:@"promoCode"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForFacebook:) name:@"didRequestForFacebook" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForTwitter:) name:@"didRequestForTwitter" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessage:) name:@"didRequestForMessage" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForWatsapp:) name:@"didRequestForWatsapp" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMail:) name:@"didRequestForMail" object:nil];


    
   
    
    
    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    
    
    _shareActionSheet = [[ UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mail",@"Message",@"Twitter",@"Facebook", nil];
    
    _shareActionSheet.delegate = self;
    
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = @"SHARE";
    
    
    if ( revealViewController ){
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        
        
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self generatePromoCode];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForFacebook" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForTwitter" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForWatsapp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForMail" object:nil];
    
    
}

-(void)tableView:(UITableView *)tableView   didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1){
        if(indexPath.row == 0){
            
            [_shareActionSheet showInView:self.view];
          
        
        }
    
    }
    

}
-(void)generatePromoCode{
    
    
    NSString *userID = [[PFUser currentUser] objectId];
    int length = (int)[userID length];

    _promoCode = [userID stringByReplacingCharactersInRange:NSMakeRange(6, length - 6) withString:@""];
    _promoCode = [ _promoCode uppercaseString];
    self.promoCodeLabel.text = _promoCode;
    
    [self.tableView reloadData];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    switch (buttonIndex) {
        case 0: //mail
            [[NSNotificationCenter defaultCenter]postNotificationName:@"didRequestForMail" object:nil];
            break;
        case 1: //message
             [[NSNotificationCenter defaultCenter]postNotificationName:@"didRequestForMessage" object:nil];
            break;
        case 2: //twitter
             [[NSNotificationCenter defaultCenter]postNotificationName:@"didRequestForTwitter" object:nil];
            break;
        case 3: //facebook
             [[NSNotificationCenter defaultCenter]postNotificationName:@"didRequestForFacebook" object:nil];
            break;

        default:
            break;
    }




}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








-(void)didRequestForFacebook:(NSNotification *)notification
{
    SLComposeViewController *fbPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString *shareText = [NSString stringWithFormat:@"Get £10 credit off your first Alfred ride. \nSign up now with the invite code: %@",_promoCode];
        [fbPost setInitialText:shareText];
    [self presentViewController:fbPost animated:YES completion:nil];
    [fbPost setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Post Canceled");
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Post Sucessful");
                break;
                
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];

    
}

-(void)didRequestForTwitter:(NSNotification *)notification
{
 
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *shareText = [NSString stringWithFormat:@"Get £10 credit off your first Alfred ride. \nSign up now with the invite code: %@",_promoCode];

        [tweetSheet setInitialText:shareText];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    

}

-(void)didRequestForMessage:(NSNotification *)notification
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    NSString *shareText = [NSString stringWithFormat:@"Get £10 credit off your first Alfred ride. \nSign up now with the invite code: %@",_promoCode];

    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
         [messageController setBody:shareText];
         [self presentViewController:messageController animated:YES completion:nil];
    
}

-(void)didRequestForWatsapp:(NSNotification *)notification
{
    NSString *shareText = [NSString stringWithFormat:@"whatsapp://send?text=Get £10 credit off your first Alfred ride. \nSign up now with the invite code: %@",_promoCode];
    
    NSURL *url = [NSURL URLWithString:[shareText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSURL *whatsappURL = url;
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Please instal Whatsapp"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)didRequestForMail:(NSNotification *)notification
{
    NSString *emailTitle = @"Alfred Share Code - Free £10 credit";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"Get £10 credit off your first Alfred ride. \nSign up now with the invite code: %@",_promoCode];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    
         [self presentViewController:mc animated:YES completion:NULL];
    
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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
