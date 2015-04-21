//
//  OrbHandler.m
//  SkyBall
//
//  Created by Steven Shing on 10/20/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import "OrbHandler.h"
#import "ViewController.h"
#import "PuckController.h"

const int kNumCorners = 4;      // Total number of corners
const int kCornerOrbScore = 30;  // Value of an orb hit in the corner
const int kCenterOrbScore = 5;  // Value of an orb hit in the center

@implementation OrbHandler {
    ViewController *_viewController;
    
    float _screenWidth; // the screen width
    float _screenHeight; // the screen height
    
    // The origin and radius of the circle the paddle is allowed to move on
    CGPoint _center;
    float _rad;
    
    float _orbRadius;                       // radius of an orb
    
    // Boundaries where orbs can be generated
    CGRect _centerOrbBoundary[5];           // 5 rects make up the boundary in the center
    CGRect _cornerOrbBoundaries[4];         // The 4 corners
    // The rectangle that encompasses the centerOrbBoundaries
    // Used to check for puck-orb collisions in that area
    CGRect _centerOrbPuckCollisionBoundary;
    
    int _currentBoundaryIndex;  // The index of the current boundary
}

//viewcontroller, screenwidth, screenheight, circleCenter, circlerad

- (id)initWithData:(ViewController *)viewController screenWidth:(float)screenWidth screenHeight:(float)screenHeight circleCenter:(CGPoint)circleCenter circleRad:(float)circleRad orbRad:(float)orbRad{
    self = [super init];
    if(self) {
        _viewController = viewController;
        _screenWidth = screenWidth;
        _screenHeight = screenHeight;
        _center = circleCenter;
        _rad = circleRad;
        
        _orbRadius = orbRad;
        
        [self setUpOrbBoundaries];
    }
    return self;
}

// HANDLE ORBS

// Add an orb to the appropriate array (center or corner)
// Takes and int param, tagNum: the tag number of the view that will be associated with the new orb
// Returns an OrbGenerator object
- (OrbGenerator*)makeOrb: (int)tagNum {
    // Used to determine the general area where the newOrb will be
    int randBoundary = arc4random_uniform(15);
    int randX;              // random x-value
    int randY;              // random y-value
    CGPoint orbLoc;         // center of the new orb
    OrbGenerator *newOrb;   // holds the new orb we make
    
    // 1 in 15 chance that the new orb in is one of the four corners
    if(randBoundary == 0) {
        // Figure out which corner we want to add the orb to
        int randCorner = arc4random_uniform(4);
        
        // Set the _currentBoundaryIndex to the appropriate corner
        if(randCorner == 0) _currentBoundaryIndex = ktopLeftBoundary;
        else if(randCorner == 1) _currentBoundaryIndex = ktopRightBoundary;
        else if(randCorner == 2) _currentBoundaryIndex = kbotRightBoundary;
        else _currentBoundaryIndex = kbotLeftBoundary;
        
        // Make sure x and y are constrained within the boundaries
        randX = arc4random_uniform(_cornerOrbBoundaries[_currentBoundaryIndex].size.width) + _cornerOrbBoundaries[_currentBoundaryIndex].origin.x;
        randY = arc4random_uniform(_cornerOrbBoundaries[_currentBoundaryIndex].size.height) + _cornerOrbBoundaries[_currentBoundaryIndex].origin.y;
        orbLoc = CGPointMake(randX, randY);
        newOrb = [[OrbGenerator alloc] initWithPosition:orbLoc rad:_orbRadius tagNumber:tagNum];
        newOrb.score = kCornerOrbScore;
        
        // Add the orb to the _cornerOrbs array
        [_viewController.cornerOrbs addObject:newOrb];
    }
    // If it's not in one of the four corners, add the orb to the center
    else
    {
        // _currentBoundaryIndex is the center
        _currentBoundaryIndex = kCenterBoundary;
        
        // Check which of the 5 center boxes the orb will be drawn too
        int randBox = arc4random_uniform(5);
        randX = arc4random_uniform(_centerOrbBoundary[randBox].size.width) + _centerOrbBoundary[randBox].origin.x;
        randY = arc4random_uniform(_centerOrbBoundary[randBox].size.height) + _centerOrbBoundary[randBox].origin.y;
        orbLoc = CGPointMake(randX, randY);
        newOrb = [[OrbGenerator alloc] initWithPosition:orbLoc rad:_orbRadius tagNumber:tagNum];
        newOrb.score = kCenterOrbScore;
        
        // Add the orb to the _centerOrbs array
        [_viewController.centerOrbs addObject:newOrb];
    }
    
    return newOrb;
}

// Set up the orb boundaries
- (void)setUpOrbBoundaries{
    // Set up the centerOrbBoundary Box
    float margin = _viewController.viewPuck.bounds.size.width;
    // center of the center boundary
    _centerOrbBoundary[0] = CGRectMake(_center.x - _rad/2 + margin, _center.y - _rad/2 + margin, _rad - 2*margin, _rad - 2*margin);
    // top of the center boundary
    _centerOrbBoundary[1] = CGRectMake(_center.x - _rad/2 + margin, _center.y - _rad/2, _rad - 2*margin, margin);
    // right of the center boundary
    _centerOrbBoundary[2] = CGRectMake(_center.x + _rad/2 - margin , _center.y - _rad/2 + margin, margin, _rad - 2*margin);
    // bottom of the center boundary
    _centerOrbBoundary[3] = CGRectMake(_center.x - _rad/2 + margin, _center.y + _rad/2 - margin, _rad - 2*margin, margin);
    // left of the center boundary
    _centerOrbBoundary[4] = CGRectMake(_center.x - _rad/2, _center.y - _rad/2 + margin, margin, _rad - 2*margin);
    
    // set up the _centerOrbPuckCollisionBoundary - this will be used when checking for collisions between the puck and an orb in the center of the screen
    // Rather than check the bounding boxes of each centerOrbBoundary Rect, check for collisions in the total area
    _centerOrbPuckCollisionBoundary = CGRectMake(_center.x - _rad/2, _center.y - _rad/2, _rad, _rad);
    
    // Set up the corner boundary boxes
    float cornerWidth = _screenWidth/4 - _orbRadius;
    // Top left
    _cornerOrbBoundaries[ktopLeftBoundary] = CGRectMake(_orbRadius, _orbRadius, cornerWidth, cornerWidth);
    // Top Right
    _cornerOrbBoundaries[ktopRightBoundary] = CGRectMake(_screenWidth - cornerWidth - _orbRadius, _orbRadius, cornerWidth, cornerWidth);
    // Bottom Right
    _cornerOrbBoundaries[kbotRightBoundary] = CGRectMake(_screenWidth - cornerWidth - _orbRadius, _screenHeight - cornerWidth - _orbRadius, cornerWidth, cornerWidth);
    // Bottom Left
    _cornerOrbBoundaries[kbotLeftBoundary] = CGRectMake(_orbRadius, _screenHeight - cornerWidth - _orbRadius, cornerWidth, cornerWidth);
}


// Check if the puck has collided with an orb
- (BOOL)checkOrbCollision: (PuckController *)puck {
    // If the puck is in the _centerOrbPuckCollisionBoundary, check for collisions
    if(CGRectIntersectsRect([puck bounds], _centerOrbPuckCollisionBoundary)) {
        for(int i = 0; i < [_viewController.centerOrbs count]; i++) {
            if([puck handleOrbCollision: _viewController.centerOrbs[i]]) {
                _inCenter = TRUE;           // The orb was in the center boundaries
                _hitOrb = _viewController.centerOrbs[i];    // Store the orb that was hit in hitOrb
                return TRUE;                // There was a collision
            }
        }
    }
    // If the puck was not in the center, check if the puck was in the corners
    else {
        for(int i = 0; i < kNumCorners; i++) {
            // If the puck is in one of the corners, check for collisions in the appropriate corner
            if(CGRectIntersectsRect([puck bounds], _cornerOrbBoundaries[i])) {
                for(int i = 0; i < [_viewController.cornerOrbs count]; i++) {
                    if([puck handleOrbCollision: _viewController.cornerOrbs[i]]) {
                        _inCenter = FALSE;          // The orb is in the corner boundaries
                        _hitOrb = _viewController.cornerOrbs[i];    // Store the orb that was hit in hitOrb
                        return TRUE;                // There was a collision
                    }
                }
            }
        }
    }
    return FALSE;   // No collision
}

- (void)showBoxes {
    // debug code to show centerOrbBoundaries
    for(int i = 0; i < 5; i++) {
        UIView *view = [[UIView alloc] initWithFrame: _centerOrbBoundary[i]];
        view.backgroundColor = [UIColor redColor];
        view.alpha = 0.25;
        [_viewController.view addSubview: view];
    }
    // debug code to show cornerOrbBoundaries
    for(int i = 0; i < 4; i++) {
        UIView *view = [[UIView alloc] initWithFrame: _cornerOrbBoundaries[i]];
        view.backgroundColor = [UIColor greenColor];
        view.alpha = 0.25;
        [_viewController.view addSubview: view];
    }
    
    // debug code to show the centerOrbPuckCollisionBoundary
    UIView *view1 = [[UIView alloc] initWithFrame:_centerOrbPuckCollisionBoundary];
    view1.backgroundColor = [UIColor yellowColor];
    view1.alpha = 0.25;
    [_viewController.view addSubview: view1];
}

@end
