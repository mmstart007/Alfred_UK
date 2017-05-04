//
//  AlfredWallet.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/22/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AlfredWallet.h"

@implementation AlfredWallet
-(id)init{

    self =  [super initWithClassName:@"Wallet"];
    if(self){
        [self setValue:@0.0f forKey:@"Balance"];
        
    }
    return self;
}


@end
