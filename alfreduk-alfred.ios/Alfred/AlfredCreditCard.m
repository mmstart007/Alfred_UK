//
//  AlfredCreditCard.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/22/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AlfredCreditCard.h"

@implementation AlfredCreditCard
-(id)initWithNumber:(NSString*)cardNumber andHolder:(NSString*)holder{
    self = [super initWithClassName:@"CreditCard"];
    if(self){
        [self setCardNumber:cardNumber];
        [self setHolderName:@"CardHolder"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"mm/yy"];
        NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
        
        [self setExpiry: [formatter stringFromDate:today]];
        
        
    }
    return self;
}
-(void)setHolderName:(NSString*)holder{
    [self setObject:holder forKey:@"CardHolder"];
}
-(void)setCardNumber:(NSString*)cardNumber{

    [self setObject:cardNumber forKey:@"CardNumber"];
}
-(void)setExpiry:(NSString*)expiry{
    [self setValue:expiry forKey:@"Expiry"];
}

-(void)setPostalCode:(NSString*)postalCode{

    [self setValue:postalCode forKey:@"PostalCode"];
}
-(NSString*)getExpiracy{
    return [self valueForKey:@"Expiracy"];
}

@end
