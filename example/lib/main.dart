import 'package:flutter/material.dart';
import 'package:flutter_music_player/flutter_music_player.dart';

void main() => runApp(new MyApp());

const musics = [
  {'url': 'https://bit.ly/2MrpveT', 'name': '1.Lemon Tree'},
  {'url': 'https://bit.ly/2N9hoja', 'name': '2.Hello, Hello, How Are You?'},
  {'url': 'https://bit.ly/2BArnwC', 'name': '3.Relaxing Pregnancy'},
];

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPlaying = 0;
  double duration = 0.0;
  double position = 0.0;
  bool isDragging = false;
  Icon icPlay = Icon(Icons.play_arrow);
  FlutterMusicPlayer player = FlutterMusicPlayer();

  @override
  void initState() {
    super.initState();
    player.onWaiting = () => this.setState(() {
          icPlay = Icon(Icons.pause);
          print('onWaiting');
        });
    player.onCanPlay = () => this.setState(() {
          icPlay = Icon(Icons.pause);
          print('onCanPlay');
        });
    player.onPlay = () => this.setState(() {
          icPlay = Icon(Icons.pause);
          print('onPlay');
        });
    player.onPause = () => this.setState(() {
          icPlay = Icon(Icons.play_arrow);
          print('onPause');
        });
    player.onStop = () => this.setState(() {
          icPlay = Icon(Icons.play_arrow);
          print('onStop');
        });
    player.onEnded = () => this.setState(() {
          icPlay = Icon(Icons.play_arrow);
          print('onEnded');
          onNextPressed();
        });
    player.onTimeUpdate = (p, d) =>
        !isDragging &&
        this.setState(() {
          position = p > d ? d : p;
          duration = d;
        });
    player.onBufferUpdate =
        (bufferPercent) => print('onBufferUpdate:' + bufferPercent.toString());
    player.start(musics[currentPlaying]['url']);
  }

  onPlayPressed() async {
    int i = await player.getState();
    switch (i) {
      case FlutterMusicPlayer.StatePlaying:
        player.pause();
        break;
      case FlutterMusicPlayer.StatePaused:
        player.play();
        break;
      case FlutterMusicPlayer.StateStopped:
        player.start(musics[currentPlaying]['url']);
        break;
    }
  }

  onPrevPressed() {
    int next = currentPlaying - 1;
    if (next < 0) next = musics.length - 1;
    cutMusic(next);
  }

  onNextPressed() {
    int next = currentPlaying + 1;
    if (next >= musics.length) next = 0;
    cutMusic(next);
  }

  cutMusic(int which) {
    player.start(musics[which]['url']);
    this.setState(() {
      currentPlaying = which;
      position = 0.0;
      duration = 0.0;
    });
  }

  onSliderChangedStart(double value) {
    this.setState(() {
      isDragging = true;
    });
  }

  onSliderChanged(double newValue) {
    this.setState(() {
      position = newValue;
    });
  }

  onSliderChangedEnd(double value) {
    player.seek(value);
    this.setState(() {
      isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter Music Player Example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                musics[currentPlaying]['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: onPrevPressed,
                ),
                IconButton(
                  icon: icPlay,
                  onPressed: onPlayPressed,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: onNextPressed,
                ),
              ],
            ),
            Slider(
              value: position,
              min: 0.0,
              max: duration,
              onChangeStart: onSliderChangedStart,
              onChanged: onSliderChanged,
              onChangeEnd: onSliderChangedEnd,
            )
          ],
        ),
      ),
    );
  }
}
