//
//  DropoffAnnotation.h
//  Alfred
//
//  Created by Arjun Busani on 27/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DropoffAnnotation : NSObject<MKAnnotation>

@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(copy,nonatomic) NSString *title;

-(id)initiWithTitle:(NSString*)newTitle Location:(CLLocationCoordinate2D)location;
-(MKAnnotationView*)annotationView;

@end
