#import "FlutterMusicPlayerPlugin.h"

@implementation FlutterMusicPlayerPlugin

FlutterMethodChannel *_channel;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    _channel = [FlutterMethodChannel
                methodChannelWithName:@"flutter_music_player"
                binaryMessenger:[registrar messenger]];
    FlutterMusicPlayerPlugin* instance = [[FlutterMusicPlayerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:_channel];
    
    // play background
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&sessionError];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"start" isEqualToString:call.method]) {
        [self start:call.arguments];
    } else if([@"play" isEqualToString:call.method]){
        [self play];
    }else if([@"pause" isEqualToString:call.method]){
        [self pause];
    }else if([@"stop" isEqualToString:call.method]){
        [self stop];
    }else if([@"seek" isEqualToString:call.method]){
        [self seek:call.arguments];
    }else if([@"getState" isEqualToString:call.method]){
        if(!_state){
            _state = STOPPED;
        }
        result(@(_state));
    }else{
        result(FlutterMethodNotImplemented);
    }
}

- (void)start:(NSString*)src {
    [self releaseAll];
    NSURL *url = [NSURL URLWithString:src];
    __weak typeof(self)weakSelf = self;
    _resourceLoaderManager = [VIResourceLoaderManager new];
    _item = [_resourceLoaderManager playerItemWithURL:url];
    VICacheConfiguration *configuration = [VICacheManager cacheConfigurationForURL:url];
    if (configuration.progress >= 1.0) {
        [_channel invokeMethod:@"onBufferUpdate" arguments:@(100)];
    }else{
        [_channel invokeMethod:@"onWaiting" arguments:nil];
    }
    _player = [AVPlayer playerWithPlayerItem:_item];
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
    if (@available(iOS 10.0, *)) {
        _player.automaticallyWaitsToMinimizeStalling = NO;
    }
    _timeObserver =
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                          queue:dispatch_queue_create("player.time.queue", NULL)
                                     usingBlock:^(CMTime time) {
                                         dispatch_async(dispatch_get_main_queue(), ^(void) {
                                             float position =  CMTimeGetSeconds(time);
                                             float duration =  CMTimeGetSeconds(weakSelf.player.currentItem.duration);
                                             NSString *json = [NSString stringWithFormat:@"{\"position\":%.3f,\"duration\":%.3f}", position, duration];
                                             [_channel invokeMethod:@"onTimeUpdate" arguments:json];
                                         });
                                     }];
}

- (void)play {
    if(_player){
        _state = PLAYING;
        [_player play];
        [_channel invokeMethod:@"onPlay" arguments:nil];
    }
}

- (void)pause {
    if(_player){
        _state = PAUSED;
        [_player pause];
        [_channel invokeMethod:@"onPause" arguments:nil];
    }
}

-(void)stop{
    _state = STOPPED;
    [self releaseAll];
    [_channel invokeMethod:@"onStop" arguments:nil];
}

-(void)seek:(NSNumber* )position{
    if(_state!=STOPPED && _player){
        CMTime duration = _player.currentItem.asset.duration;
        CMTime seekTo = CMTimeMake((NSInteger)(duration.value * [position integerValue]/CMTimeGetSeconds(_player.currentItem.duration)), duration.timescale);
        if(_state == PLAYING){
            [_channel invokeMethod:@"onWaiting" arguments:nil];
            [_player pause];
            [_player seekToTime:seekTo completionHandler:^(BOOL finished) {
                [_channel invokeMethod:@"onCanPlay" arguments:nil];
                [self play];
            }];
        }else{
            [_player seekToTime:seekTo];
        }
    }
}

-(void)releaseAll{
    if(_player){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if(_timeObserver){
            [_player removeTimeObserver:_timeObserver];
            _timeObserver = nil;
        }
        [_item removeObserver:self forKeyPath:@"status" ];
        [_item removeObserver:self forKeyPath:@"loadedTimeRanges" ];
        _player = nil;
    }
    _resourceLoaderManager = nil;
    _item = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        
        switch (itemStatus) {
            case AVPlayerItemStatusReadyToPlay:
            {
                [_channel invokeMethod:@"onCanPlay" arguments:nil];
                [self play];
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                [_channel invokeMethod:@"onError" arguments:_player.currentItem.error.localizedDescription];
            }
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  // calculate buffer percent (0-100)
        NSArray *loadedTimeRanges = [_item loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;
        CMTime duration = _item.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        CGFloat value = timeInterval / totalDuration;
        NSInteger valueInt = (NSInteger)round(value*100);
        [_channel invokeMethod:@"onBufferUpdate" arguments:@(valueInt)];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    _state = STOPPED;
    [_channel invokeMethod:@"onEnded" arguments:nil];
}

@end
