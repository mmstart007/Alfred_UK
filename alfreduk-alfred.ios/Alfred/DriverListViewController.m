//
//  DriverListViewController.m
//  
//
//  Created by Miguel Angel Carvajal on 7/21/15.
//
//

#import "DriverListViewController.h"
#import <Parse/Parse.h>

#import "DriverCalloutNotActiveViewController.h"
#import "DriverCalloutPopupViewController.h"
#import "AlfredListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface DriverListViewController (){

    int selectedIndex;
}

@end

@implementation DriverListViewController
@synthesize driverList;
@synthesize driverCalloutPopupViewController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    if (driverList.count == 0){
        
        //there are no driver, so show back label 
        self.tableView.hidden = YES;
    }
    else{
        self.tableView.hidden = NO;
    }
  
    
   // self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.rightBarButtonItem = [ [UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
//    
    
    self.navigationController.navigationBar.translucent = NO;
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForActiveDriverChosenForRide:) name:@"didRequestForActiveDriverChosenForRide" object:nil];
    
}

-(void)back{

    [self.navigationController popViewControllerAnimated:YES];

}
-(void)viewWillAppear:(BOOL)animated{

    //hide navigation bar at the top
    
 //   [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
 //                                                 forBarMetrics:UIBarMetricsDefault];
   // self.navigationController.navigationBar.shadowImage = [UIImage new];
   // self.navigationController.navigationBar.translucent = YES;
  //  self.navigationController.view.backgroundColor = [UIColor clearColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

  
}
-(void)viewDidAppear:(BOOL)animated{
    
    
   

}



-(void)viewWillDisappear:(BOOL)animated{
    
    }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.driverList.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 98;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString * identifier = @"AlfredListTableViewCell";
    PFObject *driverLocation = driverList[indexPath.row];
   
    
    
    AlfredListTableViewCell *cell = (AlfredListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == NULL){
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
       
    }
    cell.driverLocation = driverLocation;
    [cell updateData];
    
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showDriverCallout: indexPath.row];

}

-(void)showDriverCallout:(int)driverIndex{
    selectedIndex = driverIndex;
    
    
    [self performSegueWithIdentifier:@"DriverDetailsSegue" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if([[segue identifier] isEqualToString:@"DriverDetailsSegue"]){
        DriverCalloutPopupViewController *vc = (DriverCalloutPopupViewController*) segue.destinationViewController;
        vc.driverLocation = driverList[selectedIndex];
        
    }
}
-(void)didRequestForActiveDriverChosenForRide:(NSNotification *)notification
{
    
    
    
    //this array contains the following data
    // DriverID
    // RequestRideID
    // MessageboardID
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
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
