//
//  DriverRegistrationCarViewController.m
//  Alfred
//
//  Created by Arjun Busani on 21/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverRegistrationCarViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SWRevealViewController.h"
#import "DriverRegistrationInsuranceViewController.h"
#import <Parse/Parse.h>

#define PICK_IMAGE_ACTION_SHEET_TAG 100


@interface DriverRegistrationCarViewController ()<SWRevealViewControllerDelegate,UIActionSheetDelegate>
{


}
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@end

@implementation DriverRegistrationCarViewController
@synthesize uploadButton,pictureButton,urlImage,imageData;
- (void)viewDidLoad {
    
    

    [super viewDidLoad];

    [[uploadButton layer] setBorderWidth:1.0f];
    [[uploadButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
    [_userLabel setText:[NSString stringWithFormat:@"Hi, %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"Name"]] ];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(cancelPage:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    uploadButton.enabled = NO;
    
    pictureButton.layer.cornerRadius = 50;
    pictureButton.layer.masksToBounds = YES;
    
    self.userLabel.text = [NSString stringWithFormat:@"Hi, %@",[PFUser currentUser][@"FullName"]];

    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag == PICK_IMAGE_ACTION_SHEET_TAG){
        if(buttonIndex == 0 ){
        
            NSLog(@"Pick image from camera");
            [self takePhotoFromCamera];
        }
        if(buttonIndex == 1){
        
            [self takePhotoFromLibrary];
        }
        
    
    }

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

-(void)takePhotoFromLibrary{
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)uploadPicture:(id)sender {
    
    //present action sheet here
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Update your profile picture"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take picture from camera", @"Choose from gallery", nil];
    actionSheet.tag = PICK_IMAGE_ACTION_SHEET_TAG;
    [actionSheet showInView:self.view];
    
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    uploadButton.enabled = YES;
    
   
    
    UIImage *originalImage, *editedImage, *imageToSave;
    
    editedImage = (UIImage *) [info objectForKey:
                               
                               UIImagePickerControllerEditedImage];
    
    originalImage = (UIImage *) [info objectForKey:
                                 
                                 UIImagePickerControllerOriginalImage];
    imageToSave = (editedImage)?editedImage:originalImage;
    
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
    
   //TODO: make image rounded
    
    [pictureButton setBackgroundImage:imageCopy
                        forState:UIControlStateNormal];

    
    imageData = UIImageJPEGRepresentation(imageCopy, 1);
    return imageCopy;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"InsurancePush"])
    {
        DriverRegistrationInsuranceViewController *detailViewController = [segue destinationViewController];
        detailViewController.carImageData = imageData;

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
