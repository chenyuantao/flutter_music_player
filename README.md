# flutter_music_player

Flutter plugin for playing online music which is streaming-caching, background-playing, and easy-to-use.

## How to add

Add this to your package's pubspec.yaml file:
```
dependencies:
  flutter_music_player: "^0.0.1"

```
Add it to your dart file:
```
import 'package:flutter_music_player/flutter_music_player.dart';
```

## How to user

### Start to play or cut a music

```
FlutterMusicPlayer player = FlutterMusicPlayer();
player.start('http://xxx.com/xxx.mp3');
```

### Control music player

```
player.play(); // switch to play.
player.pause(); // switch to pause.
player.stop(); // stop and release the player.
player.seek(double seconds); // seek to target seconds.
```

### Handle asynchronous callbacks

```
player.onWaiting = () => print('onWaiting'); // call when initialization player, start seeking and network caching.
player.onCanPlay = () => print('onCanPlay'); // call after waiting.
player.onPlay = () => print('onPlay'); // call after switching to play.
player.onPause = () => print('onPause'); // call after switching to pause.
player.onStop = () => print('onStop'); // call when stopping.
player.onEnded = () => print('onEnded'); // call when current music playing is completed.
player.onTimeUpdate = (position, duration) => print('onTimeUpdate'); // call every second when is playing (unit seconds).
player.onBufferUpdate = (bufferPercent) => print('onBufferUpdate'); // call when the buffer update (0-100).
```

## Contact

cyt528300@gmail.com

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for more information.