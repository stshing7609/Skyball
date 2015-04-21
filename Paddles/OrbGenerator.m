//
//  OrbGenerator.m
//  SkyBall
//
//  Created by Steven Shing on 10/11/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import "OrbGenerator.h"

@implementation OrbGenerator {
    CGPoint _center;    // The orb's center
    float _radius;      // The orb's radius
}


// Initialize the orb
- (id) initWithPosition:(CGPoint)center rad:(float)rad tagNumber:(int)tagNumber{
    self = [super init];
    if(self) {
        _center = center;
        _radius = rad;
        self.tagNumber = tagNumber;
    }
    return self;
}

// Adds the object to ViewController
- (UIImageView*)addToScreen {
    CGRect frame = CGRectMake(_center.x - _radius, _center.y - _radius, _radius*2, _radius*2);
    return [[UIImageView alloc] initWithFrame:frame];
}

// Returns the center of the orb
- (CGPoint)center {
    return _center;
}

@end
