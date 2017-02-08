//
//  SearchViewController.h
//  Alfred
//
//  Created by Arjun Busani on 27/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>






@protocol AlfredSearchControllerDelegate <NSObject>

-(void)searchViewController:(id)controller didFinishedSearchWithPlacemark:(CLPlacemark*)placemark;


@end


@interface SearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,CLLocationManagerDelegate>

@property (nonatomic, weak, nullable) id<AlfredSearchControllerDelegate> delegate;

@property(strong,nonatomic)UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *places;
@property  CLLocationCoordinate2D centerPoint;


@property BOOL useCenterPoint; //shall use the center point for searching
@end
