//
//  OrbHandler.h
//  SkyBall
//
//  Created by Steven Shing on 10/20/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "OrbGenerator.h"

typedef enum{
    ktopLeftBoundary,
    ktopRightBoundary,
    kbotRightBoundary,
    kbotLeftBoundary,
    kCenterBoundary
}OrbBoundary;

static int const kMinTagNumber = 100;  // The minimum tag number for the orbs

@interface OrbHandler : NSObject
@property (strong, nonatomic) OrbGenerator* hitOrb;   // Stores an orb that the puck collided with
@property BOOL inCenter;    // True if a puck-orb collision occured in the centerBoundaries


//viewcontroller, screenwidth, screenheight, circleCenter, circlerad
- (id)initWithData:(ViewController*)viewController screenWidth:(float)screenWidth screenHeight:(float)screenHeight circleCenter:(CGPoint)circleCenter circleRad:(float)circleRad orbRad:(float)orbRad;

- (OrbGenerator*)makeOrb: (int)tagNum;

- (BOOL)checkOrbCollision: (PuckController *)puck;

- (void)showBoxes;

@end
