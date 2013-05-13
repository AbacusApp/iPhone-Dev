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
#import "UIViewController+Customizations.h"
#import "Persist.h"

#define MAX_FIRSTNAME_LENGTH        50
#define MAX_LASTNAME_LENGTH         50
#define MAX_HOURLY_RATE_LENGTH      4

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>
@property   (nonatomic, retain)     IBOutlet    UITextField     *first, *last, *rate;
@property   (nonatomic, retain)     IBOutlet    PullDown        *professions;
@property   (nonatomic, retain)     IBOutlet    UIImageView     *photo;
@property   (nonatomic, retain)     IBOutlet    UIButton        *photoButton, *closeButton, *createButton;
@property   (nonatomic, retain)     IBOutlet    UIView          *helpCallout;
@property   (nonatomic, retain)     IBOutlet    UIWebView       *helpCalloutWebview;
@property   (nonatomic, retain)     IBOutlet    UIScrollView    *scroller;
@property   (nonatomic, retain)                 UIView			*lastTextWidget;
@property   (nonatomic, retain)                 Profile         *user;


- (IBAction)addPhoto:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)createProfile:(id)sender;
@end

@implementation EditProfileViewController
@synthesize first, last, professions, rate, photo, photoButton, scroller, lastTextWidget, closeButton, createButton, helpCallout, helpCalloutWebview, user;

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
    self.user = [Database profile];
    if (self.user) {
        self.first.text = user.firstName;
        self.last.text = user.lastName;
        self.professions.text = [Database nameForProfession:user.professionID];
        self.rate.text = [NSString stringWithFormat:@"%.0f", user.hourlyRate];
        [self formatRateField];
        [self.createButton setTitle:@"UPDATE PROFILE" forState:UIControlStateNormal];
    } else {
        closeButton.hidden = YES;       // There is no profile yet so don't allow view to be closed
    }
    
    self.helpCallout.layer.shadowOpacity = 0.5;
    self.helpCallout.layer.shadowOffset = CGSizeMake(0, 1);
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCallout)] autorelease];
    [self.helpCallout addGestureRecognizer:tap];
    [self.helpCalloutWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://faq.freelanceabacus.com/pricing-callout.html"]]];

    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HourlyRateKeyboard" owner:self options:nil];
    self.rate.inputView = (UIView *)[array objectAtIndex:0];
    [((UIButton *)[self.rate.inputView viewWithTag:1]) addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];

    [((UIButton *)[self.rate.inputView viewWithTag:50]) addTarget:self action:@selector(changeRateFromKeybaord:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.rate.inputView viewWithTag:100]) addTarget:self action:@selector(changeRateFromKeybaord:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.rate.inputView viewWithTag:150]) addTarget:self action:@selector(changeRateFromKeybaord:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.rate.inputView viewWithTag:200]) addTarget:self action:@selector(changeRateFromKeybaord:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.rate.inputView viewWithTag:5]) addTarget:self action:@selector(changeRateFromKeybaord:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.rate.inputView viewWithTag:-5]) addTarget:self action:@selector(changeRateFromKeybaord:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeRateFromKeybaord:(UIButton *)button {
    if (button.tag == 5 || button.tag == -5) {
        double newValue = [rate.text doubleValue] + button.tag;
        rate.text = [NSString stringWithFormat:@"%.0f", newValue];
    } else {
        rate.text = [NSString stringWithFormat:@"%d", button.tag];
    }
}

- (void)dismissKeyboard {
    [self.lastTextWidget resignFirstResponder];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Read profile photo from saved file and alter the photo button if needed
// └────────────────────────────────────────────────────────────────────────────────────────────────────
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

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Display photo picker or actions sheet
// └────────────────────────────────────────────────────────────────────────────────────────────────────
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

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Response to action sheet - decide what kind of photo picker to display
// └────────────────────────────────────────────────────────────────────────────────────────────────────
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

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ When user selects/takes a photo, save it to a file
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *bytes = UIImagePNGRepresentation(image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *path = [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"profile.image.1"]];
    [bytes writeToFile:path atomically:YES];
    [self setProfilePhoto];
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)close:(id)sender {
    [EditProfileViewController hideModally];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Validate the user's entries and save them to the db
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (IBAction)createProfile:(id)sender {
    [lastTextWidget resignFirstResponder];
    if ([first.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Alerts showWarningWithTitle:@"Profile Details" message:@"Please enter your First name" delegate:self tag:1];
        return;
    }
    if ([last.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Alerts showWarningWithTitle:@"Profile Details" message:@"Please enter your Last name" delegate:self tag:2];
        return;
    }
    if ([professions.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Alerts showWarningWithTitle:@"Profile Details" message:@"Please select your profession" delegate:self tag:3];
        return;
    }
    if ([rate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Alerts showWarningWithTitle:@"Profile Details" message:@"Please enter your Hourly rate" delegate:self tag:4];
        return;
    }
    if (self.user) {
        user.firstName = first.text;
        user.lastName = last.text;
        user.professionID = [Database idForProfessionName:professions.text];
        user.hourlyRate = [[rate.text substringWithRange:NSRangeFromString([NSString stringWithFormat:@"1 %d", rate.text.length-4])] doubleValue];
        [Database updateProfile:self.user];
    } else {
        self.user = [[[Profile alloc] init] autorelease];
        user.firstName = first.text;
        user.lastName = last.text;
        user.professionID = [Database idForProfessionName:professions.text];
        user.hourlyRate = [[rate.text substringWithRange:NSRangeFromString([NSString stringWithFormat:@"1 %d", rate.text.length-4])] doubleValue];
        [Database addProfile:user];
        [Persist setValue:user.guid forKey:@"Active.Profile" secure:NO];
    }
    [EditProfileViewController hideModally];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PROFILE.CHANGED" object:nil];
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ When user dismisses alert for errors, set focus to appropropriate text field
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            [first becomeFirstResponder];
            break;
        case 2:
            [last becomeFirstResponder];
            break;
        case 4:
            [rate becomeFirstResponder];
            break;
    }
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ Scroll textfield into view and if hourly rate then remove the $ and /hrs
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	lastTextWidget = textField;
    CGFloat offset = lastTextWidget.frame.origin.y - lastTextWidget.frame.size.height;
    [self.scroller setContentOffset:CGPointMake(0, offset>0?offset:0) animated:YES];
    if (textField == self.rate && textField.text.length) {
        textField.text = [textField.text substringWithRange:NSRangeFromString([NSString stringWithFormat:@"1 %d", textField.text.length-4])];
    }
}

// ┌────────────────────────────────────────────────────────────────────────────────────────────────────
// │ if hourly rate then add $ and /hrs
// └────────────────────────────────────────────────────────────────────────────────────────────────────
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.rate) {
        [self formatRateField];
    }
}

- (void)formatRateField {
    self.rate.text = [NSString stringWithFormat:@"$%.0f/hr", [rate.text doubleValue]];
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
    self.helpCallout.alpha = 0;
    self.helpCallout.hidden = NO;
    [UIView animateWithDuration:.25 animations:^{
        self.helpCallout.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideCallout {
    [UIView animateWithDuration:.25 animations:^{
        self.helpCallout.alpha = 0;
    } completion:^(BOOL finished) {
        self.helpCallout.hidden = YES;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [first release];
    [last release];
    [professions release];
    [rate release];
    [photo release];
    [photoButton release];
    [scroller release];
    [lastTextWidget release];
    [closeButton release];
    [createButton release];
    [helpCallout release];
    [helpCalloutWebview release];
    [user release];
    [super dealloc];
}
@end
