//
//  SideMenuTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 24/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuTableViewController : UITableViewController
@property(nonatomic,strong)NSString* name;
@property (weak, nonatomic) UISwitch *driverSwitch;
@property(strong,nonatomic)NSDictionary* messageBoardDict;
@property(strong,nonatomic) NSString* profilePic;

@property(strong,nonatomic)NSString* storyboardType;

@end
