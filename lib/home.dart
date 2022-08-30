import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

import 'package:recorder_app/audio_player.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;
  var voice;
  List<String>? voiceList;

  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  var path;

  @override
  void initState() {
    super.initState();

    initRecorder();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    getData();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'MicroPhone Status Permisiion not Granted';
    }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    if (!isRecorderReady) return;
    path = await recorder.stopRecorder();
    final audioFile = File(path!);
    voiceList?.add(path);

    print('Recorder audio: $audioFile');

    setData(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 5, right: 5),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
              builder: (context, snapshot) {
                final duration =
                    snapshot.hasData ? snapshot.data!.duration : Duration.zero;

                String twoDigits(int n) => n.toString().padLeft(2, '0');
                final twoDigitMinutes =
                    twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds =
                    twoDigits(duration.inSeconds.remainder(60));

                return Text(
                  '${twoDigitMinutes}:${twoDigitSeconds}',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 27, 28, 30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: _animation.value,
                    spreadRadius: _animation.value,
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (recorder.isRecording) {
                    await stop();
                  } else {
                    await record();
                  }

                  setData(path.toString());

                  setState(() {});
                },
                child: Icon(
                  recorder.isRecording ? Icons.stop : Icons.play_arrow,
                  size: 70,
                  color: Colors.black,
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35)),
                  primary: Colors.red,
                ),
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    recorder.isRecording;
                    Icon(Icons.music_off);
                  },
                  icon: Icon(
                    Icons.music_note,
                    size: 50,
                  ),
                ),
                SizedBox(width: 45),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings,
                    size: 50,
                  ),
                )
              ],
            ),
            SizedBox(height: 32),
            buidText(),
            SizedBox(height: 20),
            Container(
              color: Color.fromARGB(96, 201, 146, 146),
              height: 320,
              child: ListView.builder(
                itemCount: voiceList?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(voice.toString()),
                    subtitle: Text('music'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buidText() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: 'Listen to your recorded voice ',
              style: TextStyle(color: Colors.black45)),
          TextSpan(
              text: 'Click Here',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayer(path: path),
                      ));
                }),
        ],
      ),
    );
  }

  Future<void> setData(voice) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList('voiceData', voiceList!);
  }

  void getData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    voiceList = pref.getStringList('voiceData');
  }
}
