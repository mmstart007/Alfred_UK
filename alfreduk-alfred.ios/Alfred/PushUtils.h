//
//  PushUtils.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 9/13/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushUtils : NSObject

+(void) sendPushToUser:(NSString*) userId withData:(NSDictionary*)data;
@end
