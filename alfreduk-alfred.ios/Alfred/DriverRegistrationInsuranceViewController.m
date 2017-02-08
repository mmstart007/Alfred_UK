//
//  DriverRegistrationInsuranceViewController.m
//  Alfred
//
//  Created by Arjun Busani on 21/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverRegistrationInsuranceViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DriverRegistrationLicenseViewController.h"


#define PICK_IMAGE_ACTION_SHEET_TAG 100


@interface DriverRegistrationInsuranceViewController () <UIActionSheetDelegate>

@end

@implementation DriverRegistrationInsuranceViewController
@synthesize nextButton,pictureButton,carImageData,urlImage,imageData;
- (void)viewDidLoad {
    [super viewDidLoad];

    
    [[nextButton layer] setBorderWidth:1.0f];
    [[nextButton layer] setBorderColor:[UIColor blackColor].CGColor];

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(cancelPage:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    nextButton.enabled = NO;
    
    pictureButton.layer.cornerRadius = 50;
    pictureButton.layer.masksToBounds = YES;


}
-(void)cancelPage:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    nextButton.enabled = YES;
    
    
    
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
    
    //UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
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
    
    
    [pictureButton setBackgroundImage:imageCopy
                             forState:UIControlStateNormal];
    
    
    imageData = UIImageJPEGRepresentation(imageCopy, 1);
    return imageCopy;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"LicensePush"])
    {
        DriverRegistrationLicenseViewController *detailViewController = [segue destinationViewController];
        detailViewController.carImageData = carImageData;
        detailViewController.insuranceImageData = imageData;
        
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
