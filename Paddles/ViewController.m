//
//  ViewController.m
//  Paddles
//
//  Created by Steven Shing on 9/25/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SoundBuddy2.h"
#import "PuckController.h"
#import "OrbGenerator.h"
#import "OrbHandler.h"

@interface ViewController ()

@end

const int kAddOrb = 5;          // The number of bounces before adding an orb

@implementation ViewController {
    
    float _screenWidth; // the screen width
    float _screenHeight; // the screen height
    
    CADisplayLink *_masterTimer;
    
    UIAlertView *_alert;
    
    SoundBuddy2 *_soundBuddy;
    
    // Make Paddles and pucks
    PaddleController *_paddle;
    PuckController *_puck;
    OrbHandler *_orbHandler;
    
    
    float _maxPaddleSpeed;  // The max speed the paddle can reach
    float _maxBallSpeed;    // The max speed the ball can reach
    
    CGRect _puckBox;
    CGRect _resetBox;       // Used to reset the x position of the ball after a reset
    
    int _numBounces;        // Total number of times the puck has bounced
    
    // The origin and radius of the circle the paddle is allowed to move on
    CGPoint _center;
    float _rad;
    float _orbRadius;                       // radius of an orb
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Get the width and height of the screen
    _screenWidth = self.view.bounds.size.width;
    _screenHeight = self.view.bounds.size.height;
    _soundBuddy = [[SoundBuddy2 alloc] init];
    
    // The circle's origin is the center of the screen
    _center = CGPointMake(_screenWidth/2, _screenHeight/2);
    // The radius is half the width of the screen - 1/2 the size of the paddle so that the paddle will never seem to be off screen
    _rad = _screenWidth/2 - _viewPaddle.bounds.size.width/2;
    
    // Set up maxSpeeds and the radius of orbs
    _maxPaddleSpeed = 16.0;
    _maxBallSpeed = 2.0;
    _orbRadius = 15.0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _maxPaddleSpeed = 32.0;
        _maxBallSpeed = 4.0;
        _orbRadius = 30.0;
    }
    
    _numBounces = 0;
    _tagNumber = 0;
    
    // Instantiate the orb arrays
    _centerOrbs = [[NSMutableArray alloc] init];
    _cornerOrbs = [[NSMutableArray alloc] init];
    
    [self createBoxes];
    //[self showBoxes];         // for debug
    
    _paddle = [[PaddleController alloc]
               initWithView: self.viewPaddle
               MaxSpeed: _maxPaddleSpeed
               center: _center
               radius:_rad];
    
    float paddleRadius = self.viewPaddle.bounds.size.width/2.0;
    _puck = [[PuckController alloc] initWithPuck:self.viewPuck
                                        Boundary:_puckBox
                                        ResetBox: _resetBox
                                        MaxSpeed:_maxBallSpeed
                                    PaddleRadius:paddleRadius
                                       OrbRadius:_orbRadius];
    
    _orbHandler = [[OrbHandler alloc] initWithData:self screenWidth:_screenWidth screenHeight:_screenHeight circleCenter:_center circleRad:_rad orbRad:_orbRadius];
    
    [self newGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// display a message in an alert view
- (void)displayMessage:(NSString*)msg{
    // do not display more than one message
    if(_alert) return;
    // stop animation timer
    [self stop];
    // create and show alert message
    _alert = [[UIAlertView alloc] initWithTitle: @"Game"
                                        message: msg
                                       delegate: self
                              cancelButtonTitle: @"OK"
                              otherButtonTitles: nil
    ];
    
    [_alert show];
}

- (void)newGame{
    [self reset];
    // reset score
    self.viewScore.text = @"0";
    
    // present message to start game
    [self displayMessage: @"Ready to play?"];
    // Possibly change the song every time the app restarts
    // There is a 3 in 4 chance that the first background song will play
    int rand = arc4random_uniform(4);
    if(rand > 0) _soundBuddy.bgName = kSoundBackground;
    else _soundBuddy.bgName = kSoundBackground2;
    // Play the song
    [_soundBuddy playMP3Background];
}


// called at the beginning of each round
- (void)reset{
    // reset paddle and puck
    [_paddle reset];
    [_puck reset];
    
    // bounces restart at 0
    _numBounces = 0;
    
    // Remove all orbs from the main view
    for(UIImageView *subview in [self.view subviews]) {
        if(subview.tag >= kMinTagNumber && subview.tag <= kMinTagNumber + _tagNumber) {
            [subview removeFromSuperview];
        }
    }
    
    // Clear both orb arrays
    [_centerOrbs removeAllObjects];
    [_cornerOrbs removeAllObjects];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    // message dismissed so reset our game and start animation
    _alert = nil;
    
    // check if we should start a new game
    if([self checkGameOver]){
        [self newGame];
        return;
    }
    
    // reset round
    [self reset];
    
    // start animation
    [self start];
}

// OVERRIDE TOUCHES

// The next four functions handle touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    float fingerOffset = 32.0;
    // iterate through our touch elements
    for (UITouch *touch in touches){
        // get the point of touch within the view
        CGPoint touchPoint = [touch locationInView: self.view];
        // check which half of the screen touch is on and assign
        // it to a specific paddle if not already assigned
        if (_paddle.touch == nil){
            touchPoint.y += fingerOffset;
            _paddle.touch = touch;
            [_paddle move: touchPoint];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    float fingerOffset = 32.0;
    // iterate through our touch elements
    for (UITouch *touch in touches){
        // get the point of touch within the view
        CGPoint touchPoint = [touch locationInView: self.view];
        // if the touch is assigned to our paddle then move it
        if(_paddle.touch == touch){
            touchPoint.y += fingerOffset;
            [_paddle move: touchPoint];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // iterate through our touch elements
    for (UITouch *touch in touches){
        _paddle.touch = nil;
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

// ANIMATION

- (void)animate{
    // move paddle and puck
    [_paddle animate];
    [_puck animate];
    // Handle paddle collisions which return true if a collision occurred
    if([_puck handlePaddleCollision: _paddle]) {
        _numBounces++;
        // Score a point each time you hit the puck with the paddle
        int s = [self.viewScore.text intValue];
        s ++;
        self.viewScore.text = [NSString stringWithFormat:@"%u", s];
        [_soundBuddy playSoundEffect: kSoundPaddle];
    }
    
    // Check if the puck is out of bounds
    if([self checkGameFinished]) {
        [_soundBuddy playSoundEffect:kSoundOut];
        // Stop playing the background song
        [_soundBuddy playMP3Background];
    }
    
    // If the number of bounces = kAddOrb, add a new orb to the view
    if(_numBounces == kAddOrb) {
        [self addOrbToView];
        _numBounces = 0;
    }
    
    // Check for orb collisions
    if([_orbHandler checkOrbCollision: _puck]) {
        // Score points if you hit an orb
        [_soundBuddy playSoundEffect: kSoundScore];
        _numBounces++;
        int s = [self.viewScore.text intValue];
        s += _orbHandler.hitOrb.score;
        self.viewScore.text = [NSString stringWithFormat:@"%u", s];
        
        // Remove the orb that was hit from the appropriate array
        if(_orbHandler.inCenter) [_centerOrbs removeObject:_orbHandler.hitOrb];
        else [_cornerOrbs removeObject:_orbHandler.hitOrb];
        // Remove the view of that orb from the superview
        for(UIImageView *subview in [self.view subviews]) {
            if(subview.tag == _orbHandler.hitOrb.tagNumber) {
                [subview removeFromSuperview];
                break;
            }
        }
    }
}

// starts the animation
- (void)start{
    if(_masterTimer == nil) {
        _masterTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(animate)];
        
        [_masterTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    self.viewPuck.hidden = NO;
}

// stops the animation
- (void)stop{
    if(_masterTimer != nil) {
        // remove from all run loops and nil out
        [_masterTimer invalidate];
        _masterTimer = nil;
    }
    self.viewPuck.hidden = YES;
}

// ORB STUFF

// Adds a new orb to the view
- (void)addOrbToView {
    // Make a new orb
    OrbGenerator *newOrb = [_orbHandler makeOrb:kMinTagNumber + _tagNumber];
    // Get the UIImageView for newOrb
    UIImageView *subView = [newOrb addToScreen];
    // Set the image for the new subView
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        subView.image = [UIImage imageNamed:@"orb.png"];
    else
        subView.image = [UIImage imageNamed:@"orb@2x.png"];
    // Set the tag of every orb above 99 so we can remove all of them at once when we need to reset the game
    // Make the tag of every orb different so it's easy to figure out which view to remove when the orb is destroyed
    subView.tag = kMinTagNumber + _tagNumber;
    _tagNumber++;
    
    // Add the view of the orb below the puck
    [self.view insertSubview:subView belowSubview:_viewPuck];
}

// CHECKS

// Check if the puck is out of bounds and the game is over
- (BOOL)checkGameOver{
    if(_puck.center.x > _screenWidth + _viewPuck.bounds.size.width ||
       _puck.center.x < 0 - _viewPuck.bounds.size.width ||
       _puck.center.y > _screenHeight + _viewPuck.bounds.size.height ||
       _puck.center.y < 0 - _viewPuck.bounds.size.height) {
        return TRUE;
    }
    return FALSE;
}

// check if the game is in the gameover state
- (BOOL)checkGameFinished{
    if([self checkGameOver]) {
        int s = [self.viewScore.text intValue];
        [self displayMessage:[NSString stringWithFormat: @"You scored %d points", s]];
        return TRUE;
    }
    return FALSE;
}


// HELPERS FOR THE PLAYER BOXES

- (void)createBoxes{
    // Create the bounding box of the puck
    float puckBoxMargin = 28.0;
    _puckBox = CGRectMake(puckBoxMargin, puckBoxMargin, _screenWidth - 2 * puckBoxMargin, _screenHeight - 2 * puckBoxMargin);
    
    // Create the bounding box of the respawn point for the puck
    _resetBox = CGRectMake(102, -20, 116, 49);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _resetBox = CGRectMake(265, -20, 232, 98);
    }
    
    
    // CGRectMake(x,y,width,height)
    // iPhone {40,40,240,168} & {40,273,240,168}
    // iPad   {40,40,688,440} & {40,545,688,440}
}

- (void)showBoxes{
    [_orbHandler showBoxes];
    
    // debug code to show puck box
    UIView *view2 = [[UIView alloc] initWithFrame: _puckBox];
    view2.backgroundColor = [UIColor grayColor];
    view2.alpha = 0.25;
    [self.view addSubview: view2];
    
    // debug code to show the bounding box of the puck
    UIView *view3 = [[UIView alloc] initWithFrame:[_puck bounds]];
    view3.backgroundColor = [UIColor magentaColor];
    view3.alpha = 0.25;
    [self.view addSubview: view3];
}

//PAUSE AND RESUME
- (void)pause{
    [self stop];
}

- (void)resume{
    // present a message to continue game
    [self displayMessage: @"Game Paused"];
}

// Do not allow the screen to rotate
- (BOOL)shouldAutorotate {
    return NO;
}

@end
