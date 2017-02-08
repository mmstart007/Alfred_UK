//
//  RegisterFieldTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterFieldTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *registerTextField;

@end
