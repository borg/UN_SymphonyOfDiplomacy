//
//  SoundClip.m
//  musicalExpressions
//
//  Created by Grace on 11/15/14.
//
//

#import "SoundClip.h"

@implementation SoundClip
@synthesize overlapForbidden, cancelsAllOtherSounds;

-(instancetype)initWithSoundName:(NSString*)soundName fileType:(GASoundFileType)fileType cancelsAllOtherSounds:(BOOL)cancelsSounds overlapForbidden:(float)restrictedOverlap{
    self = [super init];
    if(self){
        cancelsAllOtherSounds = cancelsSounds;
        overlapForbidden = restrictedOverlap;

        NSString *soundPath = [NSString stringWithFormat:@"sounds/%@.%@",soundName,[self stringForFileType:fileType]];
        const char *cSoundPath = [soundPath UTF8String];
        sound.loadSound(cSoundPath);
    }
    return self;
}

-(void)playSound{
    if(self.overlapForbidden == 0.0){
        sound.play();
    }else{
        float position = sound.getPosition();
        if(position == 0 || position > self.overlapForbidden){
            sound.play();
        }
    }
}

-(void)stopSound{
    sound.stop();
}

-(void)playSoundConstant{
    sound.setLoop(500);
    sound.play();
}



#pragma mark - Accessors

-(BOOL)isPlaying{
    return sound.getIsPlaying();
}

-(float)soundSpeed{
    return sound.getSpeed();
}
-(void)setSoundSpeed:(float)speed{
    sound.setSpeed(speed);
}



#pragma mark - Helpers

-(NSString*)stringForFileType:(GASoundFileType)fileType{
    if(fileType == GASoundFileTypeWav){
        return @"wav";
    }else if(fileType == GASoundFileTypeMp3){
        return @"mp3";
    }else if(fileType == GASoundFileTypeAiff){
        return @"aiff";
    }else{
        return nil;
    }
}

@end
