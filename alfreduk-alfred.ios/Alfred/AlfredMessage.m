//
//  AlfredMessage.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/22/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AlfredMessage.h"

@implementation AlfredMessage
+ (void)load {
    [self registerSubclass];
}
@dynamic city;
@dynamic date;
@dynamic closed,femaleOnly,driver;
@dynamic title,desc;
@dynamic pricePerMile,seats;
@dynamic user;
@dynamic pickAddress,dropAddress;

+(NSString*)parseClassName{
    return @"Message";
}
@end
