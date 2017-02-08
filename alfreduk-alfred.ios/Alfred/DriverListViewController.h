//
//  DriverListViewController.h
//  
//
//  Created by Miguel Angel Carvajal on 7/21/15.
//
//

#import <UIKit/UIKit.h>
#include "DriverCalloutPopupViewController.h"

@interface DriverListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *driverList;
@property (strong,nonatomic) DriverCalloutPopupViewController* driverCalloutPopupViewController;

@end
