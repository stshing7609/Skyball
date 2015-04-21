//
//  PuckController.m
//  AirHockey
//
//  Created by Tony Jefferson on 10/1/13.
//  Copyright (c) 2013 Tony Jefferson. All rights reserved.
//

#import "PuckController.h"
#import "OrbGenerator.h"

const float kPuckMinimumSpeed = 0.1;


@implementation PuckController{
    // puck view this object controls
    UIView *_view;
    
    // contains our boundary, goal1, and goal2 rects
    CGRect _rect[2];
    
     // box the puck is confined to (index into rect)
    GameRect _box;
    
    // min distance that a puck and paddle could be apart
    // equals radius of paddle + radius of puck
    // less than that is a collision
    float _minPaddleDistance;
    // same as above, but with a puck and orb
    float _minOrbDistance;
    
    float _paddleRadius;
    float _orbRadius;
}

-(id) initWithPuck: (UIView*) puck
          Boundary: (CGRect) boundary
          ResetBox: (CGRect) resetBox
          MaxSpeed: (float) max
          PaddleRadius: (float) paddleRadius
          OrbRadius:(float)orbRadius{
    self = [super init];
    if (self){
        _view = puck;
        _rect[kRectBoundary] = boundary;
        _rect[kResetBox] = resetBox;
        _maxSpeed = max;
        _paddleRadius = paddleRadius;
        _minPaddleDistance = paddleRadius + _view.bounds.size.width/2.0;
        _orbRadius = orbRadius;
        _minOrbDistance = orbRadius + _view.bounds.size.width/2.0;
       
    }
    return self;
}

// reset to starting position
-(void) reset{
    // pick a random x to drop the puck
    // TODO write method for random x value
    float x = _rect[kResetBox].origin.x + arc4random() % ((int) _rect[kResetBox].size.width);
    
    // center line
    float y = _rect[kRectBoundary].origin.x + _rect[kRectBoundary].size.height / 2;
    _view.center = CGPointMake(x, y);
    _box = kRectBoundary;
    // Set the initial speed of the ball
    _speed = 1.0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        _speed = 2.0;
    // Have the ball move in a random direction after a reset
    int randX = arc4random_uniform(3);
    int randY = arc4random_uniform(3);

    switch(randX) {
        case 0: _dx = 1;
        case 1: _dx = -1;
        default: _dx = 0;
    }
    
    if(randY == 0)
        _dy = 1;
    else if(randY == 1)
        _dy = -1;
    else if(randY == 2 && _dx != 0)
        _dy = 0;
    else
        _dy = -1;
}

// Returns the center of the puck
-(CGPoint) center{
    return _view.center;
}

// Returns the boundary of the puck
-(CGRect) bounds {
    return CGRectMake(_view.center.x - _view.bounds.size.width/2, _view.center.y - _view.bounds.size.height/2, _view.bounds.size.width, _view.bounds.size.height);
}

// Animate the puck
-(void) animate{
    // move the ball to a new position based on current direction
    // and speed
    CGPoint pos = CGPointMake(_view.center.x + _dx * _speed, _view.center.y + _dy * _speed);
   
    // Put puck into new position
    _view.center = pos;
}

// check for collision with paddle and alter path of puck if so
-(BOOL) handlePaddleCollision: (PaddleController*) paddle{
    // get our current distance from center point of rectangle
    float currentDistance = [paddle distance: _view.center];
    
    // check for true contact
    if (currentDistance <= _minPaddleDistance){
        // change the direction of the puck
        _dx = (_view.center.x - paddle.center.x) / _paddleRadius;
        _dy = (_view.center.y - paddle.center.y) / _paddleRadius;
        
        // increase the speed of the ball
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            _speed += .1;
        else
            _speed +=.2;
        
        // limit to max speed
        if (_speed > _maxSpeed) _speed = _maxSpeed;
        
        // re-position puck outside the paddle radius so we don’t hit it again
        float r = atan2(_dy,_dx);
        float x = paddle.center.x + cos(r) * (_minPaddleDistance+1);
        float y = paddle.center.y + sin(r) * (_minPaddleDistance+1);
        _view.center = CGPointMake(x,y);
        return YES;
    }
    return NO;
}


-(BOOL) handleOrbCollision: (OrbGenerator *)orb {
    // get our current distance from center point of rectangle
    CGPoint orbCenter = [orb center];
    float diffx = (orbCenter.x) - (_view.center.x);
    float diffy = (orbCenter.y) - (_view.center.y);
    float currentDistance = sqrt(diffx*diffx + diffy*diffy);
    
    // check for true contact
    if (currentDistance <= _minOrbDistance){
        // change the direction of the puck
        _dx = (_view.center.x - orb.center.x) / _orbRadius;
        _dy = (_view.center.y - orb.center.y) / _orbRadius;
        
        // increase the speed of the ball
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            _speed += .05;
        else
            _speed +=.1;
        
        // limit to max speed
        if (_speed > _maxSpeed) _speed = _maxSpeed;
        
        // re-position puck outside the orb radius so we don’t hit it again
        float r = atan2(_dy,_dx);
        float x = orb.center.x + cos(r) * (_minOrbDistance+1);
        float y = orb.center.y + sin(r) * (_minOrbDistance+1);
        _view.center = CGPointMake(x,y);
        return YES;
    }
    return NO;
}

@end
