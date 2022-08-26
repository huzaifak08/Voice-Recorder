import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as player;
import 'package:recorder_app/home.dart';

class AudioPlayer extends StatefulWidget {
  AudioPlayer({Key? key, required this.path}) : super(key: key);

  @override
  State<AudioPlayer> createState() => _AudioPlayerState(path: path);

  var path;
}

class _AudioPlayerState extends State<AudioPlayer> {
  var path;
  _AudioPlayerState({required this.path});
  final audioPlayer = player.AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    setAudio();

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == player.PlayerState.PLAYING;
      });
    });

    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.LOOP);

    // final player = AudioCache(prefix: 'assets/');
    // final url = await player.load('song.mp3');
    // audioPlayer.setUrl(url.path, isLocal: true);

    final file = File(path);
    audioPlayer.setUrl(file.path, isLocal: true);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formaTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hour = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hour, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ));
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Move Back')),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                "https://mobimg.b-cdn.net/v3/fetch/05/05eeb93a2e41734ecb6044146351f11e.jpeg",
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'The Flutter Song',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Sarah Ads',
              style: TextStyle(fontSize: 20),
            ),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await audioPlayer.seek(position);

                await audioPlayer.resume();
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formaTime(position)),
                  Text(formaTime(duration - position)),
                ],
              ),
            ),
            CircleAvatar(
              radius: 35,
              child: IconButton(
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                },
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 50,
              ),
            )
          ],
        ),
      ),
    );
  }
}
