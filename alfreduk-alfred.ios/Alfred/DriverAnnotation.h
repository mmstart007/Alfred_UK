//
//  DriverAnnotation.h
//  Alfred
//
//  Created by Arjun Busani on 25/02/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DriverAnnotation : NSObject<MKAnnotation>

@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(copy,nonatomic) NSString *title;
@property(nonatomic) NSInteger tag;
@property(nonatomic,strong)NSString* dropAddress;
@property(nonatomic,strong)NSString* dropLatitude;
@property(nonatomic,strong)NSString* dropLongitude;
@property(nonatomic,strong)NSString* requestRideId;
@property(nonatomic,strong)NSString* availbleSeats;
@property(nonatomic,strong)NSString* messageBoardId;

@property(nonatomic,strong)NSString* driverRating;
@property(nonatomic,strong)NSString* driverMobile;
@property(nonatomic,strong)NSString* driverProfilePic;


@property(nonatomic) BOOL activeRide;

@property(nonatomic,strong) NSString* driverID;

@property(nonatomic, readonly, copy) NSString *subtitle;

-(id)initWithTitle:(NSString*)newTitle Location:(CLLocationCoordinate2D)location;
-(MKAnnotationView*)annotationView;
-(void)setETA:(NSString*)eta;

@end
