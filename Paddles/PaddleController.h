//
//  PaddleController.h
//  AirHockey
//
//  Created by Student on 10/1/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaddleController : NSObject

@property (assign) UITouch *touch;
@property (readonly) float speed;
@property (assign) float maxSpeed;

// initialize object
- (id)initWithView:(UIView*)paddle MaxSpeed:(float)max center:(CGPoint)center radius:(float)rad;

// reset the position to the middle of the boundary
- (void)reset;

// set where the paddle should move tp
- (void)move:(CGPoint) pt;

- (CGPoint)findClosestPointOnCircle: (CGPoint) pt;

// center point of paddle
- (CGPoint)center;

// get distance between current paddle position and point
- (float)distance:(CGPoint)pt;

// calculate an angle using arctan
- (float)calcAngle:(CGPoint)p1 p2:(CGPoint)p2;

// animate puck view to next position without exceeding max speed
- (void)animate;

@end
