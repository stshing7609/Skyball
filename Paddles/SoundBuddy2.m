//
//  SoundBuddy2.m
//  Paddles
//
//  Created by Student on 9/26/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import "SoundBuddy2.h"

static float const kSoundEffectDefaultVolume = .7;
static float const kSoundBGDefaultVolume = .3;

@implementation SoundBuddy2 {
    NSMutableDictionary *_soundDictionary; // key:value storage
    BOOL songPlay;              // Check if we want to play the song
    AVAudioPlayer *bgPlayer;    // The player for the background music
}

- (id)init{
    self = [super init];
    if(self) {
        _soundDictionary = [NSMutableDictionary dictionary];
        [self createWavChannel: kSoundPaddle];
        [self createWavChannel: kSoundOut];
        [self createMP3Channel: kSoundScore];
        songPlay = TRUE;
    }
    return self;
}

- (void)playSoundEffect:(NSString *)fileName{
    AVAudioPlayer *player = _soundDictionary[fileName];
    player.currentTime = 0;
    [player play];
}

// Create a channel for a .wav sound file
- (void)createWavChannel:(NSString *)fileName{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    
    NSError *error;
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    
    player.volume = kSoundEffectDefaultVolume;
    
    [player prepareToPlay];
    
    _soundDictionary[fileName] = player;
}

// Create a channel for a .mp3 sound file
- (void)createMP3Channel:(NSString *)fileName{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    
    NSError *error;
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    
    player.volume = kSoundEffectDefaultVolume;
    
    [player prepareToPlay];
    
    _soundDictionary[fileName] = player;
}

// Handles the playing for a background song
- (void)playMP3Background{
    // If we want to play the sound, play it. Else stop the song
    if(songPlay) {
        songPlay = FALSE;
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:_bgName ofType:@"mp3"];
        
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        
        NSError *error;
        
        bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        
        // Background songs loop forever
        bgPlayer.numberOfLoops = -1;
        
        bgPlayer.volume = kSoundBGDefaultVolume;
        
        [bgPlayer play];
    }
    else if([bgPlayer isPlaying]){
        [bgPlayer stop];
        songPlay = TRUE;
    }
}

@end
