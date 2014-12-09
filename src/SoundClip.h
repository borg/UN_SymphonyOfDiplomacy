//
//  SoundClip.h
//  musicalExpressions
//
//  Created by Grace on 11/15/14.
//
//

#import <Foundation/Foundation.h>
#include "ofSoundStream.h"
#include "ofSoundPlayer.h"
#import "GAConstants.h"

@interface SoundClip : NSObject {
    ofSoundPlayer sound;
    BOOL cancelsAllOtherSounds;
    float overlapForbidden;
}

@property (assign,nonatomic) float overlapForbidden;
@property (assign,nonatomic) BOOL cancelsAllOtherSounds;
@property (assign,nonatomic,readonly) BOOL isPlaying;
@property (assign,nonatomic) float soundSpeed;

-(instancetype)initWithSoundName:(NSString*)soundName fileType:(GASoundFileType)fileType cancelsAllOtherSounds:(BOOL)cancelsSounds overlapForbidden:(float)overlapForbidden;

-(void)playSound;
-(void)stopSound;
-(void)playSoundConstant;

@end
