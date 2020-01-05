import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';


class SoundRecorder extends StatefulWidget {
  @override
  _SoundRecorderState createState() => _SoundRecorderState();
}

class _SoundRecorderState extends State<SoundRecorder> {
  bool _isPlaying = false;
  String _progress = '00:00:00';

  bool _isRecording = false;
  String _recordingProgress = '00:00:00';

  FlutterSound _flutterSound = FlutterSound();
  StreamSubscription<PlayStatus> _playerSubscription;
  StreamSubscription<RecordStatus> _recorderSubscription;

  _playPause() {
    if (!_isPlaying) {
      _play();
    } else {
      _stop();
    }
  }

  _play() async {
    // Copy Asset to file system
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String relativeSoundSampleDirectory = 'assets/sounds';
    String fullSoundSampleDirectory =
        '${documentsDirectory.path}/$relativeSoundSampleDirectory';
    String soundSamplePath = '$fullSoundSampleDirectory/recording.aac';
//    String soundSamplePath = '$fullSoundSampleDirectory/sample.aac';

    /*if (FileSystemEntity.typeSync(soundSamplePath) ==
        FileSystemEntityType.notFound) {
      await Directory(fullSoundSampleDirectory).create(recursive: true);
      var sampleSoundAsset = await rootBundle.load('assets/sounds/sample.aac');
      final buffer = sampleSoundAsset.buffer;
      File(soundSamplePath).writeAsBytesSync(buffer.asUint8List(
          sampleSoundAsset.offsetInBytes, sampleSoundAsset.lengthInBytes));
    }*/

//    String result = await _flutterSound.startPlayer(null);
    String result = await _flutterSound.startPlayer(soundSamplePath);

    if (_playerSubscription == null) {
      _playerSubscription = _flutterSound.onPlayerStateChanged.listen((e) async {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt());
          String txt = DateFormat('mm:ss:SS', 'en_US').format(date);

          if (!_flutterSound.isPlaying) {
            _playerSubscription.cancel();
            _playerSubscription = null;
          }

          this.setState(() {
            this._isPlaying = _flutterSound.isPlaying;
            this._progress = txt.substring(0, 8);
          });
        }
      });
    } else if (_playerSubscription.isPaused) {
      _playerSubscription.resume();
    }
  }

  _pause() async {
    String result = await _flutterSound.pausePlayer();
    _playerSubscription.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  _stop() async {
    String result = await _flutterSound.stopPlayer();
    _playerSubscription.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

//  _startStopRecording() {
//    if (!_isRecording) {
//      _startRecording();
//    } else {
//      _stopRecording();
//    }
//  }

  _startRecording(TapDownDetails tapDownDetails) async {
    debugPrint("RECORDING");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String relativeSoundSampleDirectory = 'assets/sounds';
    String fullSoundSampleDirectory =
        '${documentsDirectory.path}/$relativeSoundSampleDirectory';
    String soundSamplePath = '$relativeSoundSampleDirectory/recording.aac';

    debugPrint(soundSamplePath);
    if (FileSystemEntity.typeSync(soundSamplePath) ==
        FileSystemEntityType.notFound)
      await Directory(fullSoundSampleDirectory).create(recursive: true);

    String result = await _flutterSound.startRecorder(soundSamplePath);
    _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e) {
      DateTime date =
      new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
      String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
      this.setState(() {
        this._isRecording = true;
        this._recordingProgress = txt.substring(0, 8);
      });
    });
  }

  _stopRecording(TapUpDetails tapUpDetails) async {

    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }

    String result = await _flutterSound.stopRecorder();


    this.setState(() {
      this._isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          _recordingProgress,
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTapDown: _startRecording,
              onTapUp: _stopRecording,
              child: (!_isRecording
                  ? Icon(Icons.fiber_manual_record, size: 60,)
                  : Icon(Icons.stop,  size: 60,)),
            ),
//            IconButton(
//              icon: (!_isRecording
//                  ? Icon(Icons.fiber_manual_record)
//                  : Icon(Icons.stop)),
//              iconSize: 60,
//              onPressed: _startStopRecording,
//
//            ),
          ],
        ),
        Text(
          _progress,
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: (!_isPlaying ? Icon(Icons.play_arrow) : Icon(Icons.stop)),
              iconSize: 60,
              onPressed: _playPause,
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    _flutterSound.stopPlayer();
    super.dispose();
  }
}
