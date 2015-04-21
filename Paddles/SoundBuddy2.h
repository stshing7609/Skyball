//
//  SoundBuddy2.h
//  Paddles
//
//  Created by Student on 9/26/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

static NSString* const kSoundPaddle = @"paddle";
static NSString* const kSoundScore = @"score";
static NSString* const kSoundOut = @"out";
static NSString* const kSoundBackground = @"background";
static NSString* const kSoundBackground2 = @"background2";

@interface SoundBuddy2 : NSObject
@property (strong, nonatomic) NSString *bgName;

- (void)playSoundEffect:(NSString *)fileName;
- (void)playMP3Background;
@end
