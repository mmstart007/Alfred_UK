//
//  DriverRegistrationCarViewController.h
//  Alfred
//
//  Created by Arjun Busani on 21/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DriverRegistrationCarViewController : UIViewController<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (strong,nonatomic)NSURL *urlImage;
@property (retain)     NSData *imageData;
@end
