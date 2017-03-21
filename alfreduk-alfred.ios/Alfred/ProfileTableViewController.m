//
//  ProfileTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RidesHistoryTableViewController.h"
#import "BankInfoTableViewController.h"
#import "FXBlurView.h"
#define NAME_TEXTFIELD_TAG 102
#define PHONE_TEXTFIELD_TAG 103
#define  UPDATE_PIC_ACTION_SHEET_TAG 100

@interface ProfileTableViewController ()<SWRevealViewControllerDelegate,UITextFieldDelegate,UITableViewDelegate, UIActionSheetDelegate>{
    NSString *profileImageURL;
    NSData *_imageData;
    int _rideCount;
    int _ridePriceInCents;
    UIImage *_profilePicture;
    UIImage *_bluredProfilePicture;
    PFUser *currentUser;
    PFObject *userRatingObj;
    PFObject *driverRatingObj;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation ProfileTableViewController

- (void)hideNavigationController {
    [self.navigationController.navigationBar setTranslucent:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
 
    [self.mailLabel setText: [PFUser currentUser][@"email"]];
    [ self.phoneNumberLabel setText: [PFUser currentUser][@"Phone"] ];
    [self.nameLabel setText:[PFUser currentUser][@"FullName"]];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery includeKey:@"userRating"];
    [userQuery includeKey:@"driverRating"];
    [HUD showUIBlockingIndicatorWithText:@"Loading.."];
    [userQuery getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [HUD hideUIBlockingIndicator];
        if (error) {
            NSLog(@"Failed to get User Rating Object");
        } else {
            currentUser = (PFUser *)object;
            NSLog(@"%@", currentUser);
            userRatingObj = currentUser[@"userRating"];
            driverRatingObj = currentUser[@"driverRating"];
            if([currentUser[@"UserMode"] boolValue] == YES) {
                _rideCount = [userRatingObj[@"rideCount"] intValue];
                self.ratingView.value = [userRatingObj[@"rating"] doubleValue];
            }else{
                _rideCount = [driverRatingObj[@"rideCount"] intValue];
                self.ratingView.value = [driverRatingObj[@"rating"] doubleValue];
            }
            _ridePriceInCents = [currentUser[@"Balance"] intValue] / 100;
            self.ridesAmountLabel.text = [NSString stringWithFormat:@"%3d", _rideCount];
            self.moneyAmountLabel.text = [NSString stringWithFormat:@"%3d", _ridePriceInCents];
            [self.ratingView setNeedsDisplay];
        }
    }];

    self.tableView.delegate = self;
    
    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    
    //load the image from the server
    [self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:[PFUser currentUser][@"ProfilePicUrl"]] placeholderImage:[UIImage imageNamed:@"blank profile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //once I have the image, apply the blur and set it as the background image
            [self setBackgroudnBluredImageFromImage:image];
    }];
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.layer.frame.size.width/2;
    self.profilePicImageView.layer.masksToBounds=YES;
    self.navigationItem.backBarButtonItem.title = @"";
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    //set edit button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editProfile:)];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    self.navigationItem.title = @"Profile";
    if ( revealViewController ){
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRidesHistory" object:nil];
}

//called when pressed the button rides history from the profile view
- (void) didRequestForRidesHistory:(NSNotification *)notification {
    [self performSegueWithIdentifier:@"RidesHistory" sender:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //This line dismisses the keyboard.
    [theTextField resignFirstResponder];
    //Your view manipulation here if you moved the view up due to the keyboard etc.
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if( [segue.identifier isEqualToString:@"ShowPhoneEntry"]){
        self.navigationController.navigationItem.backBarButtonItem.title = @"Profile";
    }
}

-(void)setBackgroudnBluredImageFromImage:(UIImage*)image{

    //once I have the image, apply the blur and set it as the background image
    _profilePicture = image;
    _bluredProfilePicture = [image blurredImageWithRadius:10 iterations:3 tintColor:[UIColor clearColor]];
    [self.backgroundImageView setImage: _bluredProfilePicture];
    NSLog(@"Updated background image for view");
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == UPDATE_PIC_ACTION_SHEET_TAG) {
        if (buttonIndex == 0) {
            [self takePhotoFromCamera];
        }
        else if (buttonIndex ==1){
            [self chooseFromGallery];
        }
    }
}

-(void)takePhotoFromCamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)chooseFromGallery {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    editedImage = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    if (editedImage) {
        imageToSave = editedImage;
    } else {
        imageToSave = originalImage;
        
    }
    // UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    [self generatePhotoThumbnail:imageToSave];
}

- (void)generatePhotoThumbnail:(UIImage *)image {
    [self.profilePicImageView setImage:image];
    [self setBackgroudnBluredImageFromImage: image];
    _imageData = UIImageJPEGRepresentation(image, 1);
    [self uploadProfilePictureToServer];
}

-(void)uploadProfilePictureToServer {
    PFFile *parseImageFile = [PFFile fileWithData:_imageData];
    __block PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
    userPhoto[@"imageFile"] = parseImageFile;
    userPhoto[@"user"] = [PFUser currentUser];
    [HUD showUIBlockingIndicatorWithText:@"Updating.." ];
    [userPhoto saveInBackgroundWithBlock:^(BOOL suceedeed, NSError * error){
        [HUD hideUIBlockingIndicator];
        if(suceedeed){
            [PFUser currentUser][@"ProfilePicUrl"] = parseImageFile.url;
            [[PFUser currentUser] saveEventually];
            [self.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangedUserImage" object: parseImageFile.url];
        }else{
            NSLog(@"Failed to upload user profile picture");
        }
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 2){
        
        if(indexPath.row == 0){
            //phone number
            [self performSegueWithIdentifier:@"ShowPhoneEntry" sender:self];
            return;
        }
        if(indexPath.row == 1){
            //ride history
            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            RidesHistoryTableViewController * controller = [main instantiateViewControllerWithIdentifier:@"RidesHistoryId"];
            controller.currentUser = currentUser;
            controller.driverRideData = driverRatingObj;
            controller.userRideData = userRatingObj;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        if(indexPath.row == 2){
            //bank details
            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            BankInfoTableViewController * controller = [main instantiateViewControllerWithIdentifier:@"BankInfoTableViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        }
        if(indexPath.row == 3){
            //logout
            [PFUser logOut];
            [self performSegueWithIdentifier:@"LogoutSegue" sender:nil];
        }
    }
}

- (IBAction)updateProfile:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Update profile picture" delegate:self cancelButtonTitle:@"CANCEL" destructiveButtonTitle:nil otherButtonTitles: @"From camera",@"From gallery", nil];
    actionSheet.tag = UPDATE_PIC_ACTION_SHEET_TAG;
    [actionSheet showInView:self.view];
    
}

-(void)editProfile:(id)sender{
    [self performSegueWithIdentifier:@"editProfile" sender:nil];
}


@end
