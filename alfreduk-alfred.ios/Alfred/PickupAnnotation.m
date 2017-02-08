//
//  PickupAnnotation.m
//  Alfred
//
//  Created by Arjun Busani on 27/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "PickupAnnotation.h"

@implementation PickupAnnotation


-(id)initiWithTitle:(NSString*)newTitle Location:(CLLocationCoordinate2D)location{
    
    if (self) {
        _title = newTitle;
        _coordinate = location;
    }
    return self;
}

-(MKAnnotationView*)annotationView{
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"PickupAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    UIImage *originalImage = [UIImage imageNamed:@"pickup"];
    double imageAspectRatio = (1.0 * originalImage.size.width)/originalImage.size.height;
    UIImage *annotationImage = [self imageWithImage:originalImage scaledToSize:CGSizeMake(40 * imageAspectRatio , 40)];
    
    annotationView.image = annotationImage;
    annotationView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    annotationView.centerOffset = CGPointMake(0,-20);
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
