//
//  AlfredUser.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/22/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AlfredUser.h"

#import <Parse/PFObject+Subclass.h>


@implementation AlfredUser
@dynamic  userMode, firstName, lastName, email, phone, password, driverMode, rating, enabledAsDriver;


+ (void)load {
    [self registerSubclass];
}


-(NSString*)getFullName{
    return [NSString stringWithFormat:@"%@ %@", self.firstName  , self.lastName];

}
-(void) registerUserInAppPreferences{
   NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:self.userMode forKey:@"UserMode"];
    [prefs setValue:[self getFullName] forKey:@"Name"];
    [prefs setValue:self.email forKey:@"email"];
    [prefs setValue:self.phone forKey:@"Phone"];
    [prefs setValue:self.rating forKey:@"Rating"];
    [prefs setValue:@1234 forKey:@"PromoCode"];
    [prefs setBool:self.enabledAsDriver forKey:@"EnabledAsDriver"];
    
//    [prefs setObject:self forKey:@"AlfredUser"];
    [prefs synchronize];

}




-(void)setToUserMode{
        [self setValue:@YES forKey:@"UserMode"];
}
-(void)setToDriverMode{
    
        [self setValue:@NO forKey:@"UserMode"];

}

+(NSString*)parseClassName{

    return @"User";
}


@end
