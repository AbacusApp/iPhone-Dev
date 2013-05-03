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

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    UIImagePickerController *camera = [[[UIImagePickerController alloc] init] autorelease];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.delegate = self;
    [self presentViewController:camera animated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *bytes = UIImagePNGRepresentation(photo);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *path = [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"profile.image.1"]];
    [bytes writeToFile:path atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:^{
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
