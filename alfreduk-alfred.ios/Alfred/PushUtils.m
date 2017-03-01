//
//  PushUtils.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 9/13/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "PushUtils.h"
#import <Parse/Parse.h>


@implementation PushUtils
+(void) sendPushToUser:(PFUser*) user withData:(NSDictionary*)data{
    
    
    PFQuery * selectedDriverQuery = [PFInstallation query];
    //        [selectedDriverQuery whereKey:@"user" containedIn:@[object]];
    [selectedDriverQuery whereKey:@"user" containedIn:@[[PFUser currentUser]]];
    
    
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:selectedDriverQuery ];
    
   
    
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSLog(@"Failed to send push");
            NSLog(@"%@", error.localizedDescription);
            
        }else{
            NSLog(@"Push succeeded");
        }
        
    }];
    


}
@end
