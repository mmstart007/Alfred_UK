//
//  AppDelegate.m
//  Alfred
//
//  Created by Arjun Busani on 18/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "LoginTableViewController.h"
#import "DriverViewController.h"
#import "RiderViewController.h"

#import "GBVersionTracking/GBVersionTracking.h"
#import "ViewController.h"
#import "Stripe.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SWRevealViewController/SWRevealViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "SideMenuTableViewController.h"


@interface AppDelegate ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AppDelegate
@synthesize locationManager = _locationManager;
@synthesize window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    [Fabric with:@[[Crashlytics class]]];
    
    application.applicationIconBadgeNumber = 0;
    
    ParseClientConfiguration *configuration = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = @"u9cS3yySphS2WPsQb39R1OOhkrSKyRVzmr9nhVyg";
        configuration.clientKey = @"Hh9Qe9YiDjrwQyz9cbtzG4fzkEp8bJCuSIhcGVN0";
        configuration.server = @"https://parseapi.back4app.com";
    }];
    [Parse initializeWithConfiguration:configuration];
    
    //    [PFUser enableRevocableSessionInBackground];
    //    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [PFFacebookUtils initializeFacebook];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:56.0f/255 green:169.0f/255 blue:180.0f/255 alpha:0.2f]];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    //handle notification launching
    
    NSDictionary *remoteNotification =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if(remoteNotification!= nil){
        //opening the app from a notification
        
        NSString  *key = [remoteNotification objectForKey:@"key"];
        
        
    }
    
    [Stripe setDefaultPublishableKey:StripePublicTestKey];
    
    
    [GBVersionTracking track];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        
        //notifications types supported by the app
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        //create the notification settings
        UIUserNotificationSettings * notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        //register the notification settings on the app
        [[UIApplication sharedApplication] registerUserNotificationSettings: notificationSettings];
        
        //this is deprecated on iOS 8
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    
    
    
    //WARNING: for development purposes, skip login
    /*if ([GBVersionTracking isFirstLaunchEver]) {
     
     UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:storyboard bundle: nil];
     
     ViewController *navigationController = (ViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SplashId"];
     
     self.window.rootViewController = navigationController;
     }
     else{
     
     
     
     */
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    if (![PFUser currentUser]) {
        //this is forced, to set user mode instead of driver mode
        
        
        
        LoginTableViewController *loginViewController = (LoginTableViewController *)
        //[mainStoryboard instantiateViewControllerWithIdentifier:@"AlfredLoginViewID"];
        [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginId"];
        
        self.window.rootViewController = loginViewController;
        
        [self.window makeKeyAndVisible ];
    }else{
        
        SWRevealViewController * revealViewController = [SWRevealViewController alloc];
        
        SideMenuTableViewController *menu = (SideMenuTableViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
        if([[PFUser currentUser][@"UserMode"] boolValue]){
        
        
        
        RiderViewController *riderViewController = (RiderViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"MainPageId"];
        UINavigationController *controller = [[UINavigationController alloc]initWithRootViewController:riderViewController];
            revealViewController = [revealViewController initWithRearViewController:menu frontViewController:controller];
        self.window.rootViewController = revealViewController;
        
    }else{
        
        
        DriverViewController *driverViewController = (DriverViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"DriverMainID"];
        UINavigationController *controller = [[UINavigationController alloc]initWithRootViewController:driverViewController];
                    revealViewController = [revealViewController initWithRearViewController:menu frontViewController:controller];
        self.window.rootViewController = revealViewController;
        
        
    }
}


return YES;
}


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
    
    UIUserNotificationType types = [notificationSettings types];
    if (types  & UIUserNotificationTypeSound ){
        NSLog(@"User allowed sound notifications");
    }
    if(types & UIUserNotificationTypeAlert){
        NSLog(@"User allowed alert notifications");
    }
    if(types & UIUserNotificationTypeBadge){
        NSLog(@"User allowed badge notifications");
    }
    NSLog(@"End of user allowed notificatios");
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"content---%@", token);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:token forKey:@"deviceToken"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //forward device token to app push provider,
    //the backend in this case
    
    
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
    
    NSLog(@"Failed to register for remote notifications");
    NSLog(error.localizedDescription);
    //what happends here
    
    
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}



-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // [PFPush handlePush:userInfo];
    
    UIApplicationState state = [application applicationState];
    if(state == UIApplicationStateBackground){
        NSLog(@"======================");
        
        NSLog(@"Application is on background");
        NSLog(@"======================");
        
    }else if(state == UIApplicationStateInactive){
        NSLog(@"Application is inactive");
    }else if(state == UIApplicationStateActive){
        NSLog(@"======================");
        NSLog(@"Application is active");
        NSLog(@"======================");
    }
    
    int badgeNumber =[[UIApplication sharedApplication] applicationIconBadgeNumber];
    
    // [[UINavigationBar appearance] setTintColor: [UIColor whiteColor]];
    
    
    if (state == UIApplicationStateActive) {
        
        NSDictionary *mainAlert = [userInfo valueForKey:@"aps"] ;
        
        NSString *keyAlert = [userInfo valueForKey:@"key"];
        
        
        NSLog(@"%@", userInfo);
        NSLog(@"%@",mainAlert);
        
        /* RIDE_REQUEST */
        
        if ([keyAlert isEqualToString:@"RIDE_REQUEST"]) {
            
            NSString* requestId = userInfo[@"rid"];
            if(requestId!= NULL){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequest" object:requestId];
            }
            
        }
        
        if ([keyAlert isEqualToString:@"RIDE_REQUEST_CANCELLED"]) {
            
            NSString* rideId = mainAlert[@"rid"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:rideRequestArray];
        }
        
        if ([keyAlert isEqualToString:@"RIDE_ACCEPT"]) {
            
            NSString* rideId =userInfo[@"rid"];
            assert(rideId!=nil);
            NSArray* rideRequestArray = @[rideId];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didRequestForRideAcceptedForDriver" object:rideRequestArray];
            
        }
        if ([keyAlert isEqualToString:@"RIDE_ACCEPTED_BY_ANOTHER_DRIVER"]) {
            NSString* rideId =mainAlert[@"rideId"];
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideAcceptedByAnotherDriver" object:rideRequestArray];
        }
        
        if ([keyAlert isEqualToString:@"RIDE_ENDED"]) {
            
            NSString* rideCost = @"100";//userInfo[@"rideCost"];
            
            NSString* rideId = userInfo[@"rid"];
            NSString* whichID ;
            
            NSArray* rideRequestArray;
            
            if (userInfo[@"driverID"]) {
                whichID =mainAlert[@"driverId"];
                
            }
            else{
                whichID =mainAlert[@"userId"];
                
            }
            rideRequestArray = [[NSArray alloc] initWithObjects:rideCost,rideId,whichID, nil];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideEnd" object:rideRequestArray];
        }
        
        
        if ([keyAlert isEqualToString:@"RIDE_CANCELLED_BY_DRIVER"]) {
            
            NSString* rideId =mainAlert[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideCancelByDriver" object:rideRequestArray];
        }
        
        if ([keyAlert isEqualToString:@"REQUEST_BOARD_RIDE_STARTED"]) {
            
            NSString* rideId =mainAlert[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRideStarted" object:rideRequestArray];
        }
        
        
        if ([keyAlert isEqualToString:@"RIDE_STARTED"]) {
            
            NSString* rideId =mainAlert[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRidePickedUp" object:rideRequestArray];
        }
        
        
        if ([keyAlert isEqualToString:@"REQUEST_BOARD_RIDE_ENDED"]) {
            
            NSString* rideId =mainAlert[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRideEnded" object:rideRequestArray];
        }
        
        if ([keyAlert isEqualToString:@"RIDE_REJECTED_BY_DRIVER"]) {
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRideRejected" object:nil];
        }
        
        
        if ([keyAlert isEqualToString:@"RIDE_CANCELLED_BY_USER"]) {
            
            NSString* rideId =mainAlert[@"requestId"];
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:rideRequestArray];
        }
        
        
        if([keyAlert isEqualToString:@"DRIVER_ENABLED"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeEnabledAsDriver" object:nil];
            
            
            
        }
        
        if([keyAlert isEqualToString:@"DRIVER_DISABLED"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeDisabledAsDriver" object:nil];
            
            
            
        }
    }
    
    
    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        
        NSString *keyAlert = [userInfo valueForKey:@"key"];
        
        NSLog(@"%@",userInfo);
        
        
        if ([keyAlert isEqualToString:@"RIDE_REQUEST"]) {
            NSString* requestId =userInfo[@"rid"];
            NSLog(@"Request ID: %@",requestId);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequest" object:requestId];
            
        }
        
        
        if ([keyAlert isEqualToString:@"RIDE_REQUEST_CANCELLED"]) {
            
            NSString* rideId =userInfo[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:rideRequestArray];
        }
        
        
        
        if ([keyAlert isEqualToString:@"RIDE_ACCEPT"]) {
            
            NSString* rideId =userInfo[@"requestRideId"];
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideAcceptedForDriver" object:rideRequestArray];
            
        }
        if ([keyAlert isEqualToString:@"RIDE_ACCEPTED_BY_ANOTHER_DRIVER"]) {
            NSString* rideId =userInfo[@"rideId"];
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideAcceptedByAnotherDriver" object:rideRequestArray];
        }
        
        
        if ([keyAlert isEqualToString:@"RIDE_ENDED"]) {
            NSString* rideCost =userInfo[@"rideCost"];
            NSString* rideId =userInfo[@"rideId"];
            NSString* whichID ;
            
            NSArray* rideRequestArray;
            
            if (userInfo[@"driverId"]) {
                whichID =userInfo[@"driverId"];
                
            }
            else{
                whichID =userInfo[@"userId"];
                
            }
            rideRequestArray = [[NSArray alloc] initWithObjects:rideCost,rideId,whichID, nil];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideEnd" object:rideRequestArray];
        }
        
        
        if ([keyAlert isEqualToString:@"RIDE_CANCELLED_BY_DRIVER"]) {
            
            NSString* rideId =userInfo[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideCancelByDriver" object:rideRequestArray];
        }
        
        if ([keyAlert isEqualToString:@"REQUEST_BOARD_RIDE_STARTED"]) {
            
            NSString* rideId =userInfo[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRideStarted" object:rideRequestArray];
        }
        
        
        if ([keyAlert isEqualToString:@"RIDE_STARTED"]) {
            
            NSString* rideId =userInfo[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRidePickedUp" object:rideRequestArray];
        }
        
        if ([keyAlert isEqualToString:@"REQUEST_BOARD_RIDE_ENDED"]) {
            
            NSString* rideId =userInfo[@"rideId"];
            
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRideEnded" object:rideRequestArray];
        }
        
        if ([keyAlert isEqualToString:@"RIDE_REJECTED_BY_DRIVER"]) {
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardRideRejected" object:nil];
        }
        
    }
    
    application.applicationIconBadgeNumber = 0;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    //  [[PFFacebookUtils session] handleDidBecomeActive];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
