//
//  AlfredMessageBoardViewController.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/15/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AlfredMessageBoardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *messagesFilterButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)changeMessagesFilter:(id)sender;
- (IBAction)postANewMessage:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentFilterControl;
@end
