//
//  EditProfileViewController.m
//  Abacus
//
//  Created by Graham Savage on 5/3/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EditProfileViewController.h"
#import "UITextField+Customizations.h"
#import "AppDelegate.h"
#import "Alerts.h"
#import "Database.h"
#import "PullDown.h"
#import "WebViewController.h"

#define MAX_FIRSTNAME_LENGTH        50
#define MAX_LASTNAME_LENGTH         50
#define MAX_HOURLY_RATE_LENGTH      4

static  EditProfileViewController   *instance = nil;

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>
@property   (nonatomic, retain)     IBOutlet    UITextField     *first, *last, *rate;
@property   (nonatomic, retain)     IBOutlet    PullDown        *professions;
@property   (nonatomic, retain)     IBOutlet    UIImageView     *photo;
@property   (nonatomic, retain)     IBOutlet    UIButton        *photoButton;
@property   (nonatomic, retain)     IBOutlet    UIScrollView    *scroller;
@property   (nonatomic, retain)                 UIView			*lastTextWidget;


- (IBAction)addPhoto:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)createProfile:(id)sender;
@end

@implementation EditProfileViewController
@synthesize first, last, professions, rate, photo, photoButton, scroller, lastTextWidget;

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
    [self.rate customize];
    self.photo.layer.cornerRadius = self.photo.frame.size.width/2;
    self.photo.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.photo.layer.borderWidth = 3;
    [self setProfilePhoto];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    self.scroller.contentSize = self.scroller.bounds.size;
    [self.professions setValues:[Database professions]];
    professions.delegate = self;
    
    UIButton *help = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    [help setImage:[UIImage imageNamed:@"edit.profile.help.button.png"] forState:UIControlStateNormal];
    self.rate.rightViewMode = UITextFieldViewModeAlways;
    self.rate.rightView = help;
    [help addTarget:self action:@selector(rateHelp) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setProfilePhoto {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *path = [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"profile.image.1"]];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image) {
        self.photo.image = image;
        self.photo.hidden = NO;
        self.photo.image = image;
        self.photoButton.frame = CGRectMake(64, self.photoButton.frame.origin.y, 219, self.photoButton.frame.size.height);
        [self.photoButton setTitle:@"  CHANGE PHOTO" forState:UIControlStateNormal];
    }
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
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *bytes = UIImagePNGRepresentation(image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *path = [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"profile.image.1"]];
    [bytes writeToFile:path atomically:YES];
    [self setProfilePhoto];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PROFILE.PHOTO.CHANGED" object:nil];
    }];
}

- (IBAction)close:(id)sender {
    [EditProfileViewController hide];
}

- (IBAction)createProfile:(id)sender {
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	lastTextWidget = textField;
    CGFloat offset = lastTextWidget.frame.origin.y - lastTextWidget.frame.size.height;
    [self.scroller setContentOffset:CGPointMake(0, offset>0?offset:0) animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.first) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location == NSNotFound && !range.length) {
            return NO;
        }
        if ([textField.text length] == MAX_FIRSTNAME_LENGTH-1 && !range.length) {
            textField.text = [textField.text stringByAppendingString:string];
            return NO;
        }
        if ([textField.text length] > MAX_FIRSTNAME_LENGTH-1 && !range.length) {
            return NO;
        }
    } else if (textField == self.last) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location == NSNotFound && !range.length) {
            return NO;
        }
        if ([textField.text length] == MAX_LASTNAME_LENGTH-1 && !range.length) {
            textField.text = [textField.text stringByAppendingString:string];
            return NO;
        }
        if ([textField.text length] > MAX_LASTNAME_LENGTH-1 && !range.length) {
            return NO;
        }
    } else if (textField == self.rate) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound && !range.length) {
            return NO;
        }
        if ([textField.text length] == MAX_HOURLY_RATE_LENGTH-1 && !range.length) {
            textField.text = [textField.text stringByAppendingString:string];
            return NO;
        }
        if ([textField.text length] > MAX_HOURLY_RATE_LENGTH-1 && !range.length) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.first) {
        [last becomeFirstResponder];
    } else if (textField == last) {
        [rate becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

CGRect myFrame;
- (void)keyboardDidShow:(NSNotification *)note {
    myFrame = self.scroller.frame;
    // Resize the scroller view to sit against the top of the keyboard accessory ivew
    CGRect keyboardFrame  = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect myFrameInWindowCoordinates = [self.view convertRect:self.scroller.frame toView:self.view.window];
    myFrameInWindowCoordinates = CGRectOffset(myFrameInWindowCoordinates, 0, self.scroller.contentOffset.y);
    CGFloat diff = CGRectGetMaxY(myFrameInWindowCoordinates) - keyboardFrame.origin.y;
    if (diff > 0) {
        self.scroller.contentSize = CGSizeMake(self.scroller.contentSize.width, self.scroller.contentSize.height + diff);
    }
}

- (void)keyboardDidHide:(NSNotification *)note {
    if (lastTextWidget) {
        [UIView animateWithDuration:.25 animations:^{
            self.scroller.contentSize = CGSizeMake(myFrame.size.width, myFrame.size.height);
        } completion:^(BOOL finished) {
            myFrame = CGRectZero;
        }];
    }
}

- (void)pullDownWillDropDown:(PullDown *)pulldon {
    [first resignFirstResponder];
    [last resignFirstResponder];
    [rate resignFirstResponder];
}

- (void)rateHelp {
    WebViewController *webview = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
    webview.title = @"Abacus - FAQ";
    webview.urlString = @"http://faq.freelanceabacus.com#pricing";
    webview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.view.window.rootViewController presentModalViewController:webview animated:YES];

}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [first release];
    [last release];
    [professions release];
    [rate release];
    [photo release];
    [photoButton release];
    [scroller release];
    [lastTextWidget release];
    [super dealloc];
}
@end
