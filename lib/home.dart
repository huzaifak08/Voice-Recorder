import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';

import 'package:recorder_app/audio_player.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  var path;

  @override
  void initState() {
    super.initState();

    initRecorder();
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

    print('Recorder audio: $audioFile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            ElevatedButton(
              onPressed: () async {
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }

                setState(() {});
              },
              child: Icon(
                recorder.isRecording ? Icons.stop : Icons.mic,
                size: 80,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayer(
                          path: path,
                        ),
                      ));
                },
                child: Text('Listen to the Audio'))
          ],
        ),
      ),
    );
  }
}
