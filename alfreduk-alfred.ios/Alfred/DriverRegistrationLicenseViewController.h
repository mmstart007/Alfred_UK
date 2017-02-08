//
//  DriverRegistrationLicenseViewController.h
//  Alfred
//
//  Created by Arjun Busani on 21/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBoxButton.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

@interface DriverRegistrationLicenseViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    BOOL frontPicture;
    BOOL checked;
    float percentDone;

}
@property (weak, nonatomic) IBOutlet UIButton *rearButton;
@property (weak, nonatomic) IBOutlet UIButton *frontButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (retain)     NSData *carImageData;
@property (retain)     NSData *insuranceImageData;

@property (strong,nonatomic)NSURL *urlImage;
@property (retain)     NSData *frontImageData;
@property (retain)     NSData *backImageData;

@property (weak, nonatomic) IBOutlet CheckBoxButton *checkButton;
@property (strong, nonatomic) NSDictionary *successData;

@end
