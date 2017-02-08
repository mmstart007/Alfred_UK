//
//  MessageBoardUserJoinTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 06/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import <Parse/Parse.h>


@interface MessageBoardUserJoinTableViewController : UITableViewController<UITextFieldDelegate>
@property (weak, nonatomic)  UIButton *confirmJoin;
@property (nonatomic, strong) UITextField *priceTextField;
@property (retain, nonatomic) NSMutableArray *textFieldData;
@property(strong,nonatomic)PFObject* messageBoard;
@end
