//
//  JSONHelper.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONHelper : NSObject<NSURLConnectionDelegate>

+(NSArray *)loadJSONDataFromURLGET:(NSString *)urlString;

+(NSArray *)loadJSONDataFromURLPOST:(NSString *)urlString;

+(NSDictionary *)loadJSONDataFromURLGETDict:(NSString *)urlString;

+(NSMutableDictionary *)loadJSONDataFromURLGETDictMute:(NSString *)urlString;

+(NSMutableDictionary *)loadJSONDataFromJSONRequest:(NSString *)urlString :(NSDictionary*)jsonData;

+(NSMutableDictionary *)loadJSONDataFromMIMERequest:(NSString *)urlString :(NSData*)jsonData;

@end
