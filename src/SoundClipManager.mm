//
//  SoundClipManager.m
//  musicalExpressions
//
//  Created by Grace on 11/15/14.
//
//

#import "SoundClipManager.h"
#import "SoundClip.h"

typedef NS_ENUM(NSInteger, GAAjar) {
    GAAjarClosed,
    GAAjarOpen
};

@interface SoundClipManager ()
@property (strong,nonatomic) NSArray *sounds;
@end

@implementation SoundClipManager
@synthesize sounds,mode;

-(instancetype)init{
    return [self initWithSoundPack:GAPreloadedSoundsBeatbox];
}

-(instancetype)initWithSoundPack:(GAPreloadedSounds)soundPack{
    self = [super init];
    if(self){
        self.sounds = [[NSMutableArray alloc] init];
        
        if(soundPack == GAPreloadedSoundsBeatbox){
            [self setBeatBoxSounds];
        }else if(soundPack == GAPreloadedSoundsLatin){
            [self setLatinSounds];
        }else if(soundPack == GAPreloadedSoundsChocolateDrops){
            [self setChocolateDropSounds];
        }
        [self setFacialFeatureSounds];
        
    }
    return self;
}


#pragma mark - Individual Facial Feature Sounds

-(void)setFacialFeatureSounds{
    leftEyeBlink = [[SoundClip alloc] initWithSoundName:@"beatbox/hat4" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4];
    rightEyeBlink = [[SoundClip alloc] initWithSoundName:@"beatbox/hat3" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4];
    leftEyebrowUp = [[SoundClip alloc] initWithSoundName:@"shaker1" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:NO overlapForbidden:0.4];
    leftEyebrowDown = [[SoundClip alloc] initWithSoundName:@"scratch1" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:NO overlapForbidden:0.4];
    rightEyebrow = [[SoundClip alloc] initWithSoundName:@"beatbox/snare2" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4];
    smile = [[SoundClip alloc] initWithSoundName:@"conga4" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:NO overlapForbidden:0.4];
    pucker = [[SoundClip alloc] initWithSoundName:@"triangle1" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:NO overlapForbidden:0.4];
    blink = [[SoundClip alloc] initWithSoundName:@"beatbox/kick-rolling-hat" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4];
    mouthConstantSound = [[SoundClip alloc] initWithSoundName:@"churchy" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4];
}

-(void)updateWithMouthWidth:(float)mouthWidth mouthHeight:(float)mouthHeight leftEyebrowHeight:(float)leftEyebrowHeight leftEyeOpenness:(float)leftEyeOpenness rightEyebrowHeight:(float)rightEyebrowHeight rightEyeOpenness:(float)rightEyeOpenness{
    
    if(mode != GASoundClipManagerModeIndividualFacialFeatures) return;
    
    [self detectPuckerWithMouthWidth:mouthWidth mouthHeight:mouthHeight];
    [self updateMouthHeight:mouthHeight];
    
    [self detectBlinkWithLeftEyeOpenness:leftEyeOpenness rightEyeOpenness:rightEyeOpenness];
    
    [self updateLeftEyebrowHeight:leftEyebrowHeight];
    
    previousMouthHeight = mouthHeight;
    previousMouthWidth = mouthWidth;
    previousLeftEyebrowHeight = leftEyebrowHeight;
    previousLeftEyeOpenness = leftEyeOpenness;
    previousRightEyebrowHeight = rightEyebrowHeight;
    previousRightEyeOpenness = rightEyeOpenness;
}

//TODO: Calibration
/*
 The values below are all based on my face.
 Need to write a quick calibration thingy for new faces.
 */

-(void)detectPuckerWithMouthWidth:(float)mouthWidth mouthHeight:(float)mouthHeight{
    float widthDiff = abs(mouthWidth - previousMouthWidth);
    float heightDiff = abs(mouthHeight = previousMouthHeight);
    
    if(widthDiff > 1 && mouthHeight < 1.5){
        if(mouthWidth < 11){
            [pucker playSoundConstant];
        }else if(mouthWidth > 14){
            [smile playSoundConstant];
        }else{
            [pucker stopSound];
            [smile stopSound];
        }
    }
}

-(void)detectBlinkWithLeftEyeOpenness:(float)leftEyeOpenness rightEyeOpenness:(float)rightEyeOpenness{
    float leftEyeOpennessDiff = abs(leftEyeOpenness - previousLeftEyeOpenness);
    float rightEyeOpennessDiff = abs(rightEyeOpenness - previousRightEyeOpenness);
    
    GAAjar leftEyeDirection = leftEyeOpenness - previousLeftEyeOpenness < 0 ? GAAjarClosed : GAAjarOpen;
    GAAjar rightEyeDirection = rightEyeOpenness - previousRightEyeOpenness < 0 ? GAAjarClosed : GAAjarOpen;
    
    if(leftEyeOpennessDiff > 0.2 && rightEyeOpennessDiff > 0.2){
        
        if(leftEyeDirection == GAAjarClosed && rightEyeDirection == GAAjarClosed){
            [blink playSound];
        }
        
    }
}

-(void)updateMouthHeight:(float)mouthHeight{

    if([mouthConstantSound isPlaying]){
        if(mouthHeight < 1.5){
            [mouthConstantSound stopSound];
        }
    }else{
        if(mouthHeight > 1.5){
            [mouthConstantSound playSoundConstant];
        }
    }
    
    mouthHeight = mouthHeight / 10 + 0.5;
    if(mouthHeight < 0.3) mouthHeight = 0.3;
    if(mouthHeight > 5) mouthHeight = 5;
    
    float oldSpeed = mouthConstantSound.soundSpeed;
    
    if(abs(oldSpeed - mouthHeight) > 0.03){
        mouthConstantSound.soundSpeed = mouthHeight;
    }
}

-(void)updateLeftEyebrowHeight:(float)leftEyebrowHeight{
    float heightDiff = abs(leftEyebrowHeight - previousLeftEyebrowHeight);
    
    if(heightDiff > 0.5){
        if(leftEyebrowHeight > 8){
            [leftEyebrowUp playSoundConstant];
        }else if(leftEyebrowHeight < 7){
            [leftEyebrowDown playSound];
        }else{
            [leftEyebrowUp stopSound];
        }
    }
}

#pragma mark - Expression Classifier Sounds

-(void)setLatinSounds{
    self.sounds = @[[[SoundClip alloc] initWithSoundName:@"latin1" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"latin2" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"latin3" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"latin4" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"latin5" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"shaker1" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0]];
}

-(void)setBeatBoxSounds{
    self.sounds = @[[[SoundClip alloc] initWithSoundName:@"beatbox/kick1" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4],
                    [[SoundClip alloc] initWithSoundName:@"beatbox/open-hat" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4],
                    [[SoundClip alloc] initWithSoundName:@"beatbox/2hat2" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4],
                    [[SoundClip alloc] initWithSoundName:@"beatbox/kick-rolling-hat" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4],
                    [[SoundClip alloc] initWithSoundName:@"beatbox/hah-2" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4],
                    [[SoundClip alloc] initWithSoundName:@"beatbox/kick-rolling-snare" fileType:GASoundFileTypeWav cancelsAllOtherSounds:NO overlapForbidden:0.4]];
}

-(void)setChocolateDropSounds{
    self.sounds = @[[[SoundClip alloc] initWithSoundName:@"sample1" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"sample2" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"sample3" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"sample4" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"sample5" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0],
                    [[SoundClip alloc] initWithSoundName:@"sample6" fileType:GASoundFileTypeMp3 cancelsAllOtherSounds:YES overlapForbidden:0.0]];
}

-(void)playSoundNum:(int)soundNum{
    if(soundNum > 0){
        soundNum--;
        SoundClip *clip = self.sounds[soundNum];
        
        if(clip.cancelsAllOtherSounds){
            for(SoundClip *clipToCancel in self.sounds){
                [clipToCancel stopSound];
            }
        }
        
        [clip playSound];
    }
}


@end
