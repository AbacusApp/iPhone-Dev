//
//  EditProjectViewController.h
//  Abacus
//
//  Created by Graham Savage on 5/8/13.
//  Copyright (c) 2013 Graham Savage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"

@interface EditProjectViewController : UIViewController
@property   (nonatomic, retain)     Project     *project;
@property   (nonatomic, retain)     Calculation *calculation;
@end
