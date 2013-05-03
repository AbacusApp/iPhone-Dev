//
//  EditProfileViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UITextField+Customizations.h"
#import "AppDelegate.h"

static  EditProfileViewController   *instance = nil;

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>
@property   (nonatomic, retain)     IBOutlet    UITextField     *first, *last, *professions, *rate;

- (IBAction)addPhoto:(id)sender;
- (IBAction)hide:(id)sender;
@end

@implementation EditProfileViewController
@synthesize first, last, professions, rate;

+ (void)show {
    instance = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:nil];
    UIWindow *window = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    [window addSubview:instance.view];
    instance.view.frame = window.bounds;
    instance.view.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        instance.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

+ (void)hide {
    [UIView animateWithDuration:.25 animations:^{
        instance.view.alpha = 0;
    } completion:^(BOOL finished) {
        [instance.view removeFromSuperview];
        [instance release];
        instance = nil;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.first customize];
    [self.last customize];
    [self.professions customize];
    [self.rate customize];
}

- (IBAction)addPhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Profile Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Camera", @"Pick From Library", nil];
        [sheet showInView:self.view.window];
    } else {
        UIImagePickerController *camera = [[[UIImagePickerController alloc] init] autorelease];
        camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        camera.delegate = self;
        camera.allowsEditing = YES;
        [self presentViewController:camera animated:YES completion:^{}];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 2:
            break;
        case 0: {
            UIImagePickerController *camera = [[[UIImagePickerController alloc] init] autorelease];
            camera.sourceType = UIImagePickerControllerSourceTypeCamera;
            camera.delegate = self;
            camera.allowsEditing = YES;
            [self presentViewController:camera animated:YES completion:^{}];
        }
            break;
        case 1: {
            UIImagePickerController *camera = [[[UIImagePickerController alloc] init] autorelease];
            camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            camera.delegate = self;
            camera.allowsEditing = YES;
            [self presentViewController:camera animated:YES completion:^{}];
        }
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *photo = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *bytes = UIImagePNGRepresentation(photo);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *path = [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"profile.image.1"]];
    [bytes writeToFile:path atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PROFILE.PHOTO.CHANGED" object:nil];
    }];
}

- (IBAction)hide:(id)sender {
    [EditProfileViewController hide];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [first release];
    [last release];
    [professions release];
    [rate release];
    [super dealloc];
}
@end
