//
//  PuckController.h
//  AirHockey
//
//  Created by Tony Jefferson on 10/1/13.
//  Copyright (c) 2013 Tony Jefferson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaddleController.h"

typedef enum{
    kRectBoundary,
    kResetBox
}GameRect;

@class OrbGenerator;

@interface PuckController : NSObject

@property (readonly) float maxSpeed;
@property (readonly) float speed;
@property (readonly) float dx;
@property (readonly) float dy;

// initialize object
-(id) initWithPuck: (UIView*) puck
          Boundary: (CGRect) boundary
          ResetBox: (CGRect) resetBox
          MaxSpeed: (float) max
      PaddleRadius: (float) paddleRadius
         OrbRadius: (float) orbRadius;

// reset position to middle of boundary
-(void) reset;

// returns current center position of puck
-(CGPoint) center;

// returns a rectangular bounding box of the puck
-(CGRect) bounds;

// animate the puck
-(void)animate;

// check for collision with paddle and alter path of puck if so
-(BOOL)handlePaddleCollision:(PaddleController*) paddle;

// check for collision with orb and alter path of puck if so
-(BOOL)handleOrbCollision:(OrbGenerator*) orb;


@end
