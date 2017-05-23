//
//  DriverRegistrationLicenseViewController.m
//  Alfred
//
//  Created by Arjun Busani on 21/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//  Modified by Miguel Carvajal
//  Copyright (c) 2015 INDLABDEVELOPMENT. All rights reserved.
//

#import "DriverRegistrationLicenseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DriverRegistrationCompleteViewController.h"

#import <Parse/Parse.h>
#import "HUD.h"


#define  PICK_IMAGE_ACTION_SHEET_TAG 100


@interface DriverRegistrationLicenseViewController () <UIActionSheetDelegate>

@end

@implementation DriverRegistrationLicenseViewController
@synthesize frontButton,rearButton,submitButton,frontImageData,backImageData,carImageData,insuranceImageData,checkButton,successData;
- (void)viewDidLoad {
    [super viewDidLoad];
    frontPicture = NO;
    checked = NO;
    
    [[submitButton layer] setBorderWidth:1.0f];
    [[submitButton layer] setBorderColor:[UIColor blackColor].CGColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(cancelPage:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    frontButton.layer.cornerRadius = 50;
    frontButton.layer.masksToBounds = YES;

    rearButton.layer.cornerRadius = 50;
    rearButton.layer.masksToBounds = YES;

    submitButton.enabled = NO;
}
-(void)cancelPage:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)takeFrontPicture:(id)sender {
    frontPicture = YES;
    [self uploadPicture:sender];
    
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
        
        if(actionSheet.tag == PICK_IMAGE_ACTION_SHEET_TAG){
            
            switch (buttonIndex) {
                case 0:
                    [ self takePhotoFromCamera];
                    break;
                case 1:
                    [self takePhotoFromGallery];
                default:
                    break;
            }
        }
    }
    - (IBAction)uploadPicture:(id)sender {
        
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Update your profile picture"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take picture from camera", @"Choose from gallery", nil];
        actionSheet.tag = PICK_IMAGE_ACTION_SHEET_TAG;
        [actionSheet showInView:self.view];
        
        
    }

    
    
- (IBAction)takeBackPicture:(id)sender {

    frontPicture = NO;
    [self uploadPicture:sender];

}

-(void)takePhotoFromCamera{
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:NULL];
    
}


-(void)takePhotoFromGallery{
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    submitButton.enabled = YES;
    
    
    
    UIImage *originalImage, *editedImage, *imageToSave;
    
    editedImage = (UIImage *) [info objectForKey:
                               
                               UIImagePickerControllerEditedImage];
    
    originalImage = (UIImage *) [info objectForKey:
                                 
                                 UIImagePickerControllerOriginalImage];
    if (editedImage) {
        
        imageToSave = editedImage;
        
    } else {
        
        imageToSave = originalImage;
        
    }
    
   // UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self generatePhotoThumbnail:imageToSave];
    
}

- (UIImage *)generatePhotoThumbnail:(UIImage *)image
{
    //int kMaxResolution = 320;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (frontPicture) {
        [frontButton setBackgroundImage:imageCopy
                               forState:UIControlStateNormal];
        frontImageData = UIImageJPEGRepresentation(imageCopy, 1);

            }
    else{
        [rearButton setBackgroundImage:imageCopy
                               forState:UIControlStateNormal];
        backImageData = UIImageJPEGRepresentation(imageCopy, 1);


    }
    
    
    return imageCopy;
    
}

- (IBAction)submitForCompletion:(id)sender {
    if (!checkButton.isChecked) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Please accept the Terms and Conditions."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else if (frontImageData==nil||backImageData==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Please include front and back of your driver license."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        
        /* Register as driver */
        PFFile *frontImage = [PFFile fileWithName:@"frontImage.png" data:frontImageData];
        
        [frontImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Handle success or failure here ...
        } progressBlock:^(int percentDone) {
            // Update your progress spinner here. percentDone will be between 0 and 100.
        }];
        
        PFFile *backImage = [PFFile fileWithName:@"backImage.png" data:backImageData];
        PFFile *insuranceImage = [PFFile fileWithName:@"insuranseImage.png" data:insuranceImageData];
        PFFile *carImage = [PFFile fileWithName:@"car.png" data:carImageData];
        
        PFObject *registrationRequest = [PFObject objectWithClassName:@"RegistrationRequest"];
        registrationRequest[@"user"] = [PFUser currentUser];
        registrationRequest[@"approved"] = @NO;
        registrationRequest[@"frontImage"] = frontImage;
        registrationRequest[@"backImage"] = backImage;
        registrationRequest[@"carImage"] = carImage;
        registrationRequest[@"insuranceImage"] = insuranceImage;
        
        [HUD showUIBlockingIndicatorWithText:@"Sending for approval.."];
        
        [registrationRequest saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            
            [HUD hideUIBlockingIndicator];
            if(succeed) {
                NSLog(@"Create driver request properly");
                
                /* Enable as driver of the current user */
                /*PFUser *currentUser = [PFUser currentUser];
                currentUser[@"EnabledAsDriver"] = @YES;
                [currentUser saveInBackground]; */
                
                [self performSegueWithIdentifier:@"DriverCompletePush" sender:self];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DriverCompletePush"])
    {
        DriverRegistrationCompleteViewController *detailViewController = [segue destinationViewController];
        detailViewController.carImageData = carImageData;
        detailViewController.insuranceImageData = insuranceImageData;
        detailViewController.frontImageData = frontImageData;
        detailViewController.backImageData = backImageData;
      
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
