//
//  JSONHelper.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "JSONHelper.h"

@implementation JSONHelper

+(NSArray *)loadJSONDataFromURLGET:(NSString *)urlString{
    NSError *error;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error:&error ];
    if (!data)
    {
        NSLog(@"Download Error: %@", error.localizedDescription);
        
        // NSArray *errorWithData = [[NSArray alloc] initWithContentsOfFile:@"Error"];
        return nil;
        
    }
    
    id dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (dictionary == nil) {
        NSLog(@"JSON Error: %@", error);
        return nil;
    }
    
    NSString *myData = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    
    return dictionary;
    
}


+(NSArray *)loadJSONDataFromURLPOST:(NSString *)urlString{
    NSError *error;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    

    NSString *authValua = [self addBasicHTTPAuthenticationHeaders];
            [request setValue:authValua forHTTPHeaderField:@"Authorization"];
    NSData *data = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error:&error ];
    if (!data)
    {
        NSLog(@"Download Error: %@", error.localizedDescription);
        return nil;
    }
    
    id dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (dictionary == nil) {
        NSLog(@"JSON Error: %@", error);
        return nil;
    }
    
    return dictionary;
    
}

+(NSDictionary *)loadJSONDataFromURLGETDict:(NSString *)urlString{
    NSError *error;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error:&error ];
    if (!data)
    {
        NSLog(@"Download Error: %@", error.localizedDescription);
        return nil;
    }
    
    id dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (dictionary == nil) {
        NSLog(@"JSON Error: %@", error);
        return nil;
    }
    
    NSString *myData = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    
    return dictionary;
}


+(NSMutableDictionary *)loadJSONDataFromURLGETDictMute:(NSString *)urlString{
    NSError *error;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error:&error ];
    if (!data)
    {
        NSLog(@"Download Error: %@", error.localizedDescription);
        return nil;
        
    }
    
    id dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (dictionary == nil) {
        NSLog(@"JSON Error: %@", error);
        return nil;
    }
    
    NSString *myData = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    
    return dictionary;
}

+ (NSString*) addBasicHTTPAuthenticationHeaders
{
    NSString * wsUserName = @"EUmlZ18";
    NSString * wsPassword = @"4ff43d2ef370dfc7803050cd3cc4312396ce6b2a";
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", wsUserName, wsPassword];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]];
    
    return authValue;
}


+(NSMutableDictionary *)loadJSONDataFromJSONRequest:(NSString *)urlString :(NSDictionary*)jsonData{
    
    
    NSError *error;
    //id dictionary;
    
    //string for the URL request
    //create string for parameters that we need to send in the HTTP POST body
    NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
    
    //create a NSURL object from the string data
    NSURL *myUrl = [NSURL URLWithString:urlString];
    
    //create a mutable HTTP request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    
    
    
    //sets the receiver’s timeout interval, in seconds
    //[urlRequest setTimeoutInterval:30.0f];
    //sets the receiver’s HTTP request method
    [urlRequest setHTTPMethod:@"POST"];
    //sets the request body of the receiver to the specified data.
    [urlRequest setHTTPBody:postData];
    
    NSString *authValua = [self addBasicHTTPAuthenticationHeaders];
    [urlRequest setValue:authValua forHTTPHeaderField:@"Authorization"];

    
    //allocate a new operation queue
    //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //Loads the data for a URL request and executes a handler block on an
    //operation queue when the request completes or fails.
    
    NSData *data = [ NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error:&error ];
    
    NSString *myData = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    
    //parsing the JSON response
    id jsonObject = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:NSJSONReadingAllowFragments
                     error:&error];
    
    /*
     [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
     NSData *data,
     NSError *error) {
     if ([data length] >0 && error == nil){
     
     
     //process the JSON response
     //use the main queue so that we can interact with the screen
     dispatch_async(dispatch_get_main_queue(), ^{
     
     NSLog(@"Just Maybe");
     // [self parseResponse:data];
     
     NSString *myData = [[NSString alloc] initWithData:data
     encoding:NSUTF8StringEncoding];
     NSLog(@"JSON data = %@", myData);
     NSError *error = nil;
     
     //parsing the JSON response
     id jsonObject = [NSJSONSerialization
     JSONObjectWithData:data
     options:NSJSONReadingAllowFragments
     error:&error];
     if (jsonObject != nil && error == nil){
     NSLog(@"Successfully deserialized...");
     
     
     
     }
     
     });
     }
     else if ([data length] == 0 && error == nil){
     NSLog(@"Empty Response, not sure why?");
     }
     else if (error != nil){
     NSLog(@"Not again, what is the error = %@", error);
     }
     }];
     */
    
    return jsonObject;
    
}



+(NSMutableDictionary *)loadJSONDataFromMIMERequest:(NSString *)urlString :(NSData*)jsonData{
    NSError *error;
    NSData *postData = jsonData;
    NSURL *myUrl = [NSURL URLWithString:urlString];
    
    //create a mutable HTTP request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    
    
    
    //sets the receiver’s timeout interval, in seconds
    //[urlRequest setTimeoutInterval:30.0f];
    //sets the receiver’s HTTP request method
    [urlRequest setHTTPMethod:@"POST"];
    //sets the request body of the receiver to the specified data.
    [urlRequest setHTTPBody:postData];
    
    NSData *data = [ NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error:&error ];
    
    NSString *myData = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    
    //parsing the JSON response
    id jsonObject = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:NSJSONReadingAllowFragments
                     error:&error];
    
    return jsonObject;
    
    
}


@end
