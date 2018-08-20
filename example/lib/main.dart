import 'package:flutter/material.dart';
import 'package:flutter_music_player/flutter_music_player.dart';

void main() => runApp(new MyApp());

const musics = [
  {
    'url':
        'http://fs.open.kugou.com/fb85aeca2a4a841b50a1108ef390ff59/5b7a658b/G093/M01/0C/08/nQ0DAFiOyGiAJXFkADpFudDpIqU734.mp3',
    'name': '1.Fade - Alan Walker'
  },
  {
    'url':
        'http://fs.open.kugou.com/7168732cb3b98c86a85d942f0c9e7a84/5b7a6756/G067/M0A/0B/1B/44YBAFejRSKAMHi9ADw_2LCAxko000.mp3',
    'name': '2.Fade Again - Jiaye'
  },
  {
    'url':
        'http://fs.open.kugou.com/28cba8533f3e2f279f827a204bd32c10/5b7a67ad/G067/M06/06/09/gw0DAFe4XJCAaxIDADAYAiNTIDA273.mp3',
    'name': '3.Life - Tobu'
  },
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
    player.onTimeUpdate = (p, bufferPercent, d) =>
        !isDragging &&
        this.setState(() {
          position = p > d ? d : p;
          duration = d;
        });
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
