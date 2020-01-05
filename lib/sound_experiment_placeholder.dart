//
//import 'package:flutter_sound/flutter_sound.dart';
//import 'package:intl/intl.dart';
//import 'package:path_provider/path_provider.dart';
//
//class Player extends StatefulWidget {
//  @override
//  _PlayerState createState() => _PlayerState();
//}
//
//class _PlayerState extends State<Player> {
//  bool _isPlaying = false;
//  String _progress = '00:00:00';
//
//  FlutterSound _flutterSound = FlutterSound();
//  StreamSubscription<PlayStatus> _playerSubscription;
//
//  _playPause() {
//    if (!_isPlaying) {
//      _play();
//    } else {
//      _pause();
//    }
//  }
//
//  _play() async {
//    // Copy Asset to file system
//    Directory documentsDirectory = await getApplicationDocumentsDirectory();
//    String relativeSoundSampleDirectory = 'assets/sounds';
//    String fullSoundSampleDirectory =
//        '${documentsDirectory.path}/$relativeSoundSampleDirectory';
//    String soundSamplePath = '$fullSoundSampleDirectory/sample.aac';
//
//    if (FileSystemEntity.typeSync(soundSamplePath) ==
//        FileSystemEntityType.notFound) {
//      await Directory(fullSoundSampleDirectory).create(recursive: true);
//      var sampleSoundAsset = await rootBundle.load('assets/sounds/sample.aac');
//      final buffer = sampleSoundAsset.buffer;
//      File(soundSamplePath).writeAsBytesSync(buffer.asUint8List(
//          sampleSoundAsset.offsetInBytes, sampleSoundAsset.lengthInBytes));
//    }
//
//    String result = await _flutterSound.startPlayer(soundSamplePath);
//
//    if (_playerSubscription == null) {
//      _playerSubscription = _flutterSound.onPlayerStateChanged.listen((e) {
//        if (e != null) {
//          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
//              e.currentPosition.toInt());
//          String txt = DateFormat('mm:ss:SS', 'en_ZA').format(date);
//          this.setState(() {
//            this._isPlaying = true;
//            this._progress = txt.substring(0, 8);
//          });
//        }
//      });
//    } else if (_playerSubscription.isPaused) {
//      _playerSubscription.resume();
//    }
//  }
//
//  _pause() async {
//    String result = await _flutterSound.pausePlayer();
//    _playerSubscription.pause();
//    setState(() {
//      _isPlaying = false;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      children: <Widget>[
//        Text(
//          _progress,
//          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
//        ),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            IconButton(
//              icon: (!_isPlaying ? Icon(Icons.play_arrow) : Icon(Icons.pause)),
//              iconSize: 60,
//              onPressed: _playPause,
//            ),
//          ],
//        )
//      ],
//    );
//  }
//
//  @override
//  void dispose() {
//    _flutterSound.stopPlayer();
//    super.dispose();
//  }
//}