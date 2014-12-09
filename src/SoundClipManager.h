//
//  SoundClipManager.h
//  musicalExpressions
//
//  Created by Grace on 11/15/14.
//
//

#import <Foundation/Foundation.h>
#import "GAConstants.h"
@class SoundClip;

typedef NS_ENUM(NSInteger, GASoundClipManagerMode) {
    GASoundClipManagerModeExpressionClassifier,
    GASoundClipManagerModeIndividualFacialFeatures
};

@interface SoundClipManager : NSObject {
    NSArray *sounds;
    
    SoundClip *mouthConstantSound;
    SoundClip *leftEyeBlink;
    SoundClip *rightEyeBlink;
    SoundClip *leftEyebrowUp;
    SoundClip *leftEyebrowDown;
    SoundClip *rightEyebrow;
    SoundClip *smile;
    SoundClip *pucker;
    SoundClip *blink;
    
    float previousMouthWidth;
    float previousMouthHeight;
    float previousLeftEyebrowHeight;
    float previousLeftEyeOpenness;
    float previousRightEyebrowHeight;
    float previousRightEyeOpenness;
    
    GASoundClipManagerMode mode;
}

@property (assign,nonatomic) int mode;

-(instancetype)initWithSoundPack:(GAPreloadedSounds)soundPack;

-(void)playSoundNum:(int)soundNum;

-(void)updateWithMouthWidth:(float)mouthWidth mouthHeight:(float)mouthHeight leftEyebrowHeight:(float)leftEyebrowHeight leftEyeOpenness:(float)leftEyeOpenness rightEyebrowHeight:(float)rightEyebrowHeight rightEyeOpenness:(float)rightEyeOpenness;

@end
