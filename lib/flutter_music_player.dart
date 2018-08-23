import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

typedef void VoidCallback();
typedef void TimeCallback(double position, double duration);
typedef void ErrorCallback(String message);
typedef void BufferCallback(int bufferPercent);

class FlutterMusicPlayer {
  static const MethodChannel _channel =
      const MethodChannel('flutter_music_player');

  VoidCallback onWaiting;
  VoidCallback onCanPlay;
  VoidCallback onPlay;
  VoidCallback onPause;
  VoidCallback onStop;
  VoidCallback onEnded;
  BufferCallback onBufferUpdate;
  TimeCallback onTimeUpdate;
  ErrorCallback onError;

  FlutterMusicPlayer() {
    _channel.setMethodCallHandler(_methondCallHandler);
  }
  Future _methondCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onWaiting':
        onWaiting != null && onWaiting();
        break;
      case 'onCanPlay':
        onCanPlay != null && onCanPlay();
        break;
      case 'onPlay':
        onCanPlay != null && onPlay();
        break;
      case 'onPause':
        onCanPlay != null && onPause();
        break;
      case 'onStop':
        onCanPlay != null && onStop();
        break;
      case 'onEnded':
        onCanPlay != null && onEnded();
        break;
      case 'onTimeUpdate':
        Map<String, dynamic> map = jsonDecode(call.arguments);
        onTimeUpdate != null && onTimeUpdate(map['position'], map['duration']);
        break;
      case 'onBufferUpdate':
        onBufferUpdate != null && onBufferUpdate(call.arguments);
        break;
      case 'onError':
        onCanPlay != null && onError(call.arguments);
        break;
    }
  }

  Future<void> start(String url) => _channel.invokeMethod('start', url);

  Future<void> play() => _channel.invokeMethod('play');

  Future<void> pause() => _channel.invokeMethod('pause');

  Future<void> stop() => _channel.invokeMethod('stop');

  Future<void> seek(double seconds) => _channel.invokeMethod('seek', seconds);

  Future<int> getState() async {
    return await _channel.invokeMethod('getState');
  }

  static const StateStopped = 1;
  static const StatePlaying = 2;
  static const StatePaused = 3;
}
