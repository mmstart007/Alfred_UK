//
//  DriverAnnotation.m
//  Alfred
//
//  Created by Arjun Busani on 25/02/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverAnnotation.h"

@implementation DriverAnnotation
@synthesize driverID,dropAddress,dropLatitude,dropLongitude,requestRideId,availbleSeats,activeRide;
@synthesize subtitle;


-(id)initWithTitle:(NSString*)newTitle Location:(CLLocationCoordinate2D)location{
    self = [super init];
    
    if (self) {
        _title = newTitle;
        _coordinate = location;
        subtitle = @"Calculating time of arrival";
    }
    return self;
}

-(void)setTag:(NSInteger)tag{
    _tag = tag;
    
}

-(void)setETA:(NSString *)eta{
    subtitle = eta;

}

-(MKAnnotationView*)annotationView{
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"DriverAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    UIImage *originalImage = [UIImage imageNamed:@"blank logo"];
    UIImage *annotationImage = [self imageWithImage:originalImage scaledToSize:CGSizeMake(40, 35)];
    annotationView.image = annotationImage;
    
    return annotationView;
}



-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
