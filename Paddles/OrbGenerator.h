//
//  OrbGenerator.h
//  SkyBall
//
//  Created by Steven Shing on 10/11/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuckController.h"

@interface OrbGenerator : NSObject

@property int score;        // score value of an orb
@property int tagNumber;    // tag value of an orb (used when managing views)

// Initialize the object
- (id)initWithPosition: (CGPoint)center rad:(float)rad tagNumber:(int)tagNumber;

// Adds the object to ViewController
- (UIImageView*)addToScreen;

// returns current center position of the orb
- (CGPoint)center;

@end
