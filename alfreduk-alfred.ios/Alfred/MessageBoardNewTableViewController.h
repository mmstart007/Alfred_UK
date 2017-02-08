//
//  MessageBoardNewTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickLocationViewController.h"


#import "HUD.h"
#import "MessageBoardNewPostDelegate.h"




@interface MessageBoardNewTableViewController : UITableViewController<UITextFieldDelegate, UITextViewDelegate, UITextFieldDelegate>
{
    BOOL isItPick;
    int price;

    BOOL isItDriver;
    BOOL isPickupChecked,isDropoffChecked;

}


@property(strong,nonatomic)NSString* dateString;
//@property(strong,nonatomic)NSString* title;

@property (weak, nonatomic)  UIButton *pickupButton;
@property (weak, nonatomic)  UIButton *dropoffButton;

@property(strong,nonatomic)PickLocationViewController *pickLocationViewController;

@property(strong,nonatomic) NSString* pickupAddress,*dropoffAddress;




@property (retain, nonatomic) NSMutableArray *textFieldData;






@property(strong,nonatomic)NSString* city;

@property double pickLat,pickLong,dropLat,dropLong;
@property (weak) id< MessageBoardNewPostDelegate> messageBoardNewPostDelegate;



@end



