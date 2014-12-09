//
//  GAConstants.h
//  musicalExpressions
//
//  Created by Grace on 11/16/14.
//
//

//Borg, externalising all config values makes it more portable

//#define GAScreenWidth 1280  // 1280 1440
//#define GAScreenHeight 720  // 720 900


//#define GAVideoWidth 426  // 1280 1440
//#define GAVideoHeight 240  // 720 900


typedef NS_ENUM(NSInteger, GASoundFileType) {
    GASoundFileTypeWav,
    GASoundFileTypeMp3,
    GASoundFileTypeAiff
};

typedef NS_ENUM(NSInteger, GAPreloadedSounds) {
    GAPreloadedSoundsBeatbox,
    GAPreloadedSoundsLatin,
    GAPreloadedSoundsChocolateDrops
};

typedef NS_ENUM(NSInteger, GACalibrationState) {
    GACalibrationStateNeutral,
    GACalibrationStateSmile,
    GACalibrationStatePout,
    GACalibrationStateMouthOpen,
    GACalibrationStateEyebrowsUp,
    GACalibrationStateEyebrowsDown,
    GACalibrationStateClosedEyes,
    GACalibrationStateDone
};