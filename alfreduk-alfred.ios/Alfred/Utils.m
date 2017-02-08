//
//  Utils.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 3/21/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "Utils.h"
@import UIKit;

@implementation Utils
+(void)alertError:(NSString*)errorString{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
    [view show];

}
@end
