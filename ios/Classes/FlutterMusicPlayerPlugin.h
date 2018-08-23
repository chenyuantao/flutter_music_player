#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import "VIMediaCache.h"

@interface FlutterMusicPlayerPlugin : NSObject<FlutterPlugin>
typedef NS_ENUM(NSInteger, State) {
    STOPPED = 1,
    PLAYING = 2,
    PAUSED = 3
};
@property (strong, nonatomic)AVPlayer *player;
@property (strong, nonatomic)AVPlayerItem *item;
@property (strong, nonatomic)VIResourceLoaderManager *resourceLoaderManager;
@property (strong, nonatomic)id timeObserver;
@property (nonatomic,readwrite) State state;
@end
