//
//  AppDelegate.m
//  Alfred
//
//  Created by Arjun Busani on 18/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AppDelegate.h"
#import <Instabug/Instabug.h>
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
    
    // Setup Instabug
    [Instabug startWithToken:@"cffcbde018bdf1456464686a8b484859" invocationEvent:IBGInvocationEventNone];
    [Instabug setUserStepsEnabled:YES];
    
    // Setup Fabric
    [Fabric with:@[[Crashlytics class]]];
    
    application.applicationIconBadgeNumber = 0;
    
    ParseClientConfiguration *configuration = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = @"9QHSHL0i0s2QzyQlm9jJHrg2SO4PaUq3RigxCr0C";
        configuration.clientKey = @"VQQczLwx8qjk5wEVD36bYQuPDTEwguaKFC8uQTtj";
        configuration.server = @"https://parseapi.back4app.com";
    }];
    [Parse initializeWithConfiguration:configuration];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [PFFacebookUtils initializeFacebook];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary *remoteNotification =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if(remoteNotification!= nil){
        //opening the app from a notification
        
        //NSString  *key = [remoteNotification objectForKey:@"key"];
        
    }
    
    //[[STPPaymentConfiguration sharedConfiguration] setPublishableKey:@"pk_test_4Tqbf4pCpIlnN7JOIx5Llp9W"];
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
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    if (![PFUser currentUser]) {
        //this is forced, to set user mode instead of driver mode
        LoginTableViewController *loginViewController = (LoginTableViewController *)
        //[mainStoryboard instantiateViewControllerWithIdentifier:@"AlfredLoginViewID"];
        [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginId"];
        
        self.window.rootViewController = loginViewController;
        
        [self.window makeKeyAndVisible ];
    } else {
        
        SWRevealViewController * revealViewController = [SWRevealViewController alloc];
        
        SideMenuTableViewController *menu = (SideMenuTableViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
        if([[PFUser currentUser][@"UserMode"] boolValue]){
            RiderViewController *riderViewController = (RiderViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"MainPageId"];
            UINavigationController *controller = [[UINavigationController alloc]initWithRootViewController:riderViewController];
            revealViewController = [revealViewController initWithRearViewController:menu frontViewController:controller];
            self.window.rootViewController = revealViewController;
            
        } else {
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
    NSLog(@"%@", error.localizedDescription);
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
        // Ride request Canceled by Passenger. will receive to Driver
        if ([keyAlert isEqualToString:@"REQUEST_CANCEL"]) {
            
            NSString* rideId = userInfo[@"rid"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:rideId];
        }
        // Ride request Canceled by Driver. will receive to Passenger
        if ([keyAlert isEqualToString:@"RIDE_REJECT"]) {
            
            NSString *message = mainAlert[@"alert"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideCancelByDriver" object:message];
        }
        // Ride Canceled by Passenger. will receive to Driver
        if ([keyAlert isEqualToString:@"RIDE_CANCEL_PASSENGER"]) {
            
            NSString* rideId =userInfo[@"rid"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:rideId];
        }
        // Ride Canceled by Driver. wukk receuve to Passenger
        if ([keyAlert isEqualToString:@"RIDE_CANCEL_DRIVER"]) {
            
            NSString *message = mainAlert[@"alert"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideCancelByDriver" object:message];
        }
        if ([keyAlert isEqualToString:@"RIDE_ACCEPT"]) {
            
            NSString* driverId =userInfo[@"driverID"];
            assert(driverId != nil);
            NSArray* rideRequestArray = @[driverId, mainAlert[@"alert"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideAcceptedForDriver" object:rideRequestArray];
        }
        if ([keyAlert isEqualToString:@"RIDE_END_DRIVER"]) {
            
            NSString* rideId = userInfo[@"rid"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideEnd" object:rideId];
        }
        
        
        
        
        if ([keyAlert isEqualToString:@"RIDE_ACCEPTED_BY_ANOTHER_DRIVER"]) {
            NSString* rideId =mainAlert[@"rideId"];
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideAcceptedByAnotherDriver" object:rideRequestArray];
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
        if([keyAlert isEqualToString:@"DRIVER_ENABLED"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeEnabledAsDriver" object:nil];
        }
        if([keyAlert isEqualToString:@"DRIVER_DISABLED"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeDisabledAsDriver" object:nil];
        }
    }

    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        
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
        // Ride request Canceled by Passenger. will receive to Driver
        if ([keyAlert isEqualToString:@"REQUEST_CANCEL"]) {
            
            NSString* rideId = userInfo[@"rid"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:rideId];
        }
        // Ride request Canceled by Driver. will receive to Passenger
        if ([keyAlert isEqualToString:@"RIDE_REJECT"]) {
            
            NSString *message = mainAlert[@"alert"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideCancelByDriver" object:message];
        }
        // Ride Canceled by Passenger. will receive to Driver
        if ([keyAlert isEqualToString:@"RIDE_CANCEL_PASSENGER"]) {
            
            NSString* rideId =userInfo[@"rid"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:rideId];
        }
        // Ride Canceled by Driver. wukk receuve to Passenger
        if ([keyAlert isEqualToString:@"RIDE_CANCEL_DRIVER"]) {
            
            NSString *message = mainAlert[@"alert"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideCancelByDriver" object:message];
        }
        if ([keyAlert isEqualToString:@"RIDE_ACCEPT"]) {
            
            NSString* driverId =userInfo[@"driverID"];
            assert(driverId != nil);
            NSArray* rideRequestArray = @[driverId, mainAlert[@"alert"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideAcceptedForDriver" object:rideRequestArray];
        }
        if ([keyAlert isEqualToString:@"RIDE_END_DRIVER"]) {
            
            NSString* rideId = userInfo[@"rid"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideEnd" object:rideId];
        }
        
        
        
        
        if ([keyAlert isEqualToString:@"RIDE_ACCEPTED_BY_ANOTHER_DRIVER"]) {
            NSString* rideId =mainAlert[@"rideId"];
            NSArray* rideRequestArray = [[NSArray alloc] initWithObjects:rideId, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideAcceptedByAnotherDriver" object:rideRequestArray];
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
        if([keyAlert isEqualToString:@"DRIVER_ENABLED"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeEnabledAsDriver" object:nil];
        }
        if([keyAlert isEqualToString:@"DRIVER_DISABLED"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeDisabledAsDriver" object:nil];
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
