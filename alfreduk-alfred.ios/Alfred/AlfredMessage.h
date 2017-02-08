//
//  AlfredMessage.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/22/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <Parse/Parse.h>
#import "AlfredUser.h"

/*!
 @abstract represents a message board message that can be posted as driver or user
 */

@interface AlfredMessage : PFObject <PFSubclassing>

@property (strong,nonatomic) NSString *pickAddress, *dropAddress;
@property (strong,nonatomic) NSString *title, *desc;
@property NSString* seats;
@property BOOL closed,femaleOnly,driver;
@property int pricePerMile;
@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) PFUser *user;
@property (strong,nonatomic) NSString* city;

+(NSString*)parseClassName;

@end
