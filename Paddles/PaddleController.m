//
//  PaddleController.m
//  AirHockey
//
//  Created by Student on 10/1/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import "PaddleController.h"
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(degrees) degrees*(M_PI/180)

const int kRotateSpeed = 12; // Speed at which the paddle rotates (in degrees)

@implementation PaddleController {
    UIView *_view;          // paddle view with current position
    CGPoint _pos;           // position paddle is moving to
    CGPoint _pathCenter;    // The center of the circle path
    float _r;               // The radius of the circle path
    float _padAngle;        // The angle the paddle is at in the circle
    float _posAngle;        // The angle of the position the paddle is going to move to
}

- (id) initWithView:(UIView*)paddle MaxSpeed:(float)max center:(CGPoint)center  radius:(float)rad{
    self = [super init];
    if(self) {
        _view = paddle;
        self.maxSpeed = max;
        _pathCenter = center;
        _r = rad;
        _padAngle = [self calcAngle:_view.center p2:_pathCenter];
        _posAngle = _padAngle;
    }
    return self;
}

// reset to starting position
- (void) reset {
    _pos.x = _pathCenter.x * 2 - _view.bounds.size.width/2;
    _pos.y = _pathCenter.y;
    _view.center = _pos;
    _padAngle = [self calcAngle:_view.center p2:_pathCenter];
    _posAngle = _padAngle;
}

// set where paddle will be moving to
- (void) move: (CGPoint) pt{
    // move the paddle to the closest point on the circle to the touch.
    // if the touch is at the center of the circle, do nothing
    // Also set the angle of the touch
    if(pt.x != _pathCenter.x && pt.y != _pathCenter.y) {
        CGPoint locOnCircle = [self findClosestPointOnCircle:pt];
        // update the position
        _pos = locOnCircle;
        _posAngle = [self calcAngle:_pos p2:_pathCenter];
        
        /*NSLog(@"padAngle: %f, posAngle: %f, _pos.x: %f, _pos.y: %f, _pathCenter.x: %f, _pathCenter.y: %f, _view.center.x: %f, _view.center.y: %f", _padAngle, _posAngle, _pos.x, _pos.y, _pathCenter.x, _pathCenter.y, _view.center.x, _view.center.y);
        float temp = _posAngle*180/M_PI;
        float temp2 = _padAngle*180/M_PI;
        NSLog(@"padAngle: %f, posAngle: %f", temp2, temp);*/
    }
}

// Takes the player's touch and finds the closest point on the circle to the touch
- (CGPoint) findClosestPointOnCircle: (CGPoint)pt {
    // The fixed circle path has it's center at the center of the screen.
    // It's radius is half the width
    // Find the distance of the point from the center of the circle
    float magV = sqrtf(powf(pt.x-_pathCenter.x, 2.0) + powf(pt.y - _pathCenter.y, 2.0));
    // Calculate the x value and the y value of the closest point on the circle to the touch
    float closestX = _pathCenter.x + _r * ((pt.x - _pathCenter.x)/magV);
    float closestY = _pathCenter.y + _r * ((pt.y - _pathCenter.y)/magV);
    
    return CGPointMake(closestX, closestY);
}

// center point of paddle
- (CGPoint)center {
    return _view.center;
}

// get distance between current paddle position and point
- (float) distance:(CGPoint)pt {
    float diffx = (_view.center.x) - (pt.x);
    float diffy = (_view.center.y) - (pt.y);
    return sqrt(diffx*diffx + diffy*diffy);
}

// animate paddle to move to position without exceeding max speed
-(void) animate{
    // check if movement is needed
    if (CGPointEqualToPoint(_view.center, _pos) == false){
        float d = [self distance: _pos];    // calculate distance we need to move
        float currAngle = _padAngle;        // The current angle the paddle is at
        int direction = 0;                  // The direction the paddle is travelling
        // check the maximum distance paddle is allowed to move
        if (d > self.maxSpeed)
        {
            // Find the shortest path the paddle can travel and take that path
            // Quads 2 and 4
            // Paddle in 2, touch in 4
            if(_padAngle < DEGREES_TO_RADIANS(180) && _padAngle > DEGREES_TO_RADIANS(90) && _posAngle > DEGREES_TO_RADIANS(270)){
                if(_padAngle > DEGREES_TO_RADIANS(135)) direction = 1;
                else direction = -1;
            }
            // Paddle in 4, touch in 2
            else if(_padAngle > DEGREES_TO_RADIANS(270) && _posAngle < DEGREES_TO_RADIANS(180) && _posAngle > DEGREES_TO_RADIANS(90)){ if(_padAngle < DEGREES_TO_RADIANS(315)) direction = -1;
                else direction = 1;
            }
            // Quads 1 and 3
            // Paddle in 1, touch in 3
            else if(_padAngle < DEGREES_TO_RADIANS(90) && _posAngle > DEGREES_TO_RADIANS(180) && _posAngle < DEGREES_TO_RADIANS(270)){ if(_padAngle > DEGREES_TO_RADIANS(45))direction = 1;
                else direction = -1;
            }
            // Paddle in 3, touch in 1
            else if(_padAngle > DEGREES_TO_RADIANS(180) && _padAngle < DEGREES_TO_RADIANS(270) && _posAngle < DEGREES_TO_RADIANS(90)){ if(_padAngle < DEGREES_TO_RADIANS(225))direction = -1;
                else direction = 1;
            }
            // Quads 1 and 4 are special cases since we are crossing over the 0/360 degree line
            // Quads 1 and 4
            else if(_padAngle < DEGREES_TO_RADIANS(90) && _posAngle > DEGREES_TO_RADIANS(270)) direction = -1;
            else if(_padAngle > DEGREES_TO_RADIANS(270) && _posAngle < DEGREES_TO_RADIANS(90)) direction = 1;
            // If none of the above are true, head in the positive direction if the angle of the touch is greater than the angle of the paddle, else go in the negative direction
            else if(_posAngle >= _padAngle) direction = 1;
            else if(_posAngle < _padAngle) direction = -1;
            
            // Rotate the paddle kRotateSpeed degrees every frame
            currAngle += DEGREES_TO_RADIANS(kRotateSpeed)*direction;
            
            // Make sure the angle of the paddle is between 0 and 360 degrees
            if(currAngle > DEGREES_TO_RADIANS(360)) currAngle -= DEGREES_TO_RADIANS(360);
            if(currAngle < DEGREES_TO_RADIANS(0)) currAngle += DEGREES_TO_RADIANS(360);
            
            // Update the position of the paddle
            float x = _r*cos(currAngle) + _pathCenter.x;
            float y = _r*sin(currAngle) + _pathCenter.y;
            _view.center = CGPointMake(x,y);
        
            _speed = self.maxSpeed;
            _padAngle = currAngle;  // Update the angle of the paddle
        }
    }else {
        // not moving
        _speed = 0;
    }
}

// Calculates an angle using arctan
- (float)calcAngle:(CGPoint)p1 p2:(CGPoint)p2 {
    float angle = atan2f(p1.y - p2.y, p1.x - p2.x);
    if(angle > DEGREES_TO_RADIANS(360)) angle -= DEGREES_TO_RADIANS(360);
    if(angle < DEGREES_TO_RADIANS(0)) angle += DEGREES_TO_RADIANS(360);
    return angle;
}

@end
