//
//  ShareTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface ShareTableViewController : UITableViewController<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
{
    NSString *promoCode;
}


@property (weak, nonatomic) IBOutlet UILabel *promoCodeLabel;



@end
