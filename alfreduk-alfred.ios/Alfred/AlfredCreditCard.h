//
//  AlfredCreditCard.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/22/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <Parse/Parse.h>
/*!
 @abstract Store credict card info in Parse Cloud Storage
 */

@interface AlfredCreditCard : PFObject
-(id)initWithNumber:(NSString*)cardNumber andHolder:(NSString*)holder;
-(void)setHolderName:(NSString*)holder;
-(void)setCardNumber:(NSString*)cardNumber;
-(void)setExpiry:(NSString*)expiry;
-(NSString*)getExpiracy;
-(void)setPostalCode:(NSString*)postalCode;

@end
