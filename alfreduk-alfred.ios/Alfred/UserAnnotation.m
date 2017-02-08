//
//  UserAnnotation.m
//  Alfred
//
//  Created by Arjun Busani on 07/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "UserAnnotation.h"

@implementation UserAnnotation


-(id)initiWithTitle:(NSString*)newTitle Location:(CLLocationCoordinate2D)location{
    
    if (self) {
        _title = newTitle;
        _coordinate = location;
    }
    return self;
}

-(MKAnnotationView*)annotationView{
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"UserAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    UIImage *originalImage = [UIImage imageNamed:@"users"];
    UIImage *annotationImage = [self imageWithImage:originalImage scaledToSize:CGSizeMake(40, 45)];
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
