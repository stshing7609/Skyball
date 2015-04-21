//
//  ViewController.h
//  Paddles
//
//  Created by Steven Shing on 9/25/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaddleController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *viewPaddle;
@property (weak, nonatomic) IBOutlet UIView *viewPuck;
@property (weak, nonatomic) IBOutlet UILabel *viewScore;
@property (strong, nonatomic) NSMutableArray *centerOrbs;
@property (strong, nonatomic) NSMutableArray *cornerOrbs;
@property int tagNumber;             // The tag of the view for the orb

- (void)pause;
- (void)resume;

@end
