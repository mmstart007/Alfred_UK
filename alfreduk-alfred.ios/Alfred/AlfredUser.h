//
//  AlfredUser.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/22/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <Parse/Parse.h>


/*!
 @abstract Represent the User entity stored in the server
 */
@interface AlfredUser : PFObject<PFSubclassing>
@property (nonatomic) BOOL userMode;
@property (nonatomic) BOOL driverMode;
@property (nonatomic) BOOL enabledAsDriver;
@property (strong, nonatomic) NSString *firstName,*lastName,*email,*phone, *password;
@property (strong,nonatomic) NSNumber *rating;


+(NSString*)parseClassName;


-(NSString*)getFullName;


/*!
 @abstract register the user data in the app preferences
 */
-(void) registerUserInAppPreferences;


-(void)setToUserMode;
-(void)setToDriverMode;



@end
