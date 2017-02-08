//
//  MessageBoardPersonalEditTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"

@interface MessageBoardPersonalEditTableViewController : UITableViewController<UITextViewDelegate>
@property(strong,nonatomic)NSString* messageBoardId;
@property(strong,nonatomic)NSString* subject;
@property (nonatomic, strong) UITextView *messageTextView;
@property (retain, nonatomic) NSMutableArray *textFieldData;
@property (weak, nonatomic)  UIButton *confirmEdit;
@property BOOL isItDriver;

@end
