import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String _databasePath = 'resounder.db';

class Sound {
  final int id;
  final String name;

  Sound({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  Sound.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'];
}

class SoundProvider {
  static Database _database;

  static Future<Database> open(_databasePath) async {
    if (_database != null) return _database;

    _database = await openDatabase(_databasePath, version: 1,
        onCreate: (db, version) async {
      await db
          .execute("CREATE TABLE sounds(id INTEGER PRIMARY KEY, name TEXT)");
    });
    return _database;
  }

  static _checkOpen() {
    if (_database == null || !_database.isOpen) {
      throw Exception(
          "Open should be called before using any of the provider functions");
    }
  }

  static Future<Sound> insert(Sound sound) async {
    _checkOpen();
    int id = await _database.insert('sounds', sound.toMap());
    return Sound(id: id, name: sound.name);
  }

  static Future<List<Sound>> queryAll() async {
    _checkOpen();
    var soundRecords = await _database.query('sounds');
    return soundRecords.map((record) => Sound.fromMap(record)).toList();
  }

  static Future close() async {
    _database.close();
    _database = null;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Resounder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Resounder"),
          ),
          body: Container(
            padding: EdgeInsets.only(top: 12),
            child: SoundList(),
          ),
          floatingActionButton: Builder(
              builder: (context) => FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewSoundRoute()),
                      );
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.green,
                  )),
        ));
  }
}

class SoundList extends StatefulWidget {
  @override
  _SoundListState createState() => _SoundListState();
}

class _SoundListState extends State<SoundList> {
  List<Sound> soundList = <Sound>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  _refreshList() async {
    SoundProvider.open(_databasePath);
    var newSoundList = await SoundProvider.queryAll();
    debugPrint('Query Called: ${newSoundList.length}');

    setState(() {
      soundList = newSoundList;
    });
  }

  Widget _buildSoundList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: soundList.length,
        itemBuilder: (context, i) {
          return _buildSoundRow(soundList[i]);
        });
  }

  Widget _buildSoundRow(Sound sound) {
    return
      Column(children: <Widget>[
        ListTile(
          title: Text(
            sound.name,
            style: _biggerFont,
          ),
          trailing: Text(
            '${sound.id}',
            style: _biggerFont,
          ),
        ),
        Divider()
      ],
      );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Refresh List"),
            onPressed: _refreshList,
          ),
          Expanded(
            child: _buildSoundList(),
          )
        ],
      ),
    );
  }
}

class NewSoundRoute extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  Sound _sound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New Sound'),
        ),
        body: Column(children: <Widget>[
          Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please specify a name';
                  }
                  _sound = Sound(name: value);
                  return null;
                },
              )),
          Builder(
            builder: (context) {
              return RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await SoundProvider.open(_databasePath);
                    _sound = await SoundProvider.insert(_sound);

                    Scaffold
                        .of(context)
                        .showSnackBar(SnackBar(content: Text('Sound Saved')));
                  }
                },
                child: Text("Save"),
              );
            },
          )
        ]));
  }
}

class Player extends StatefulWidget {
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool _isPlaying = false;
  String _progress = '00:00:00';

  FlutterSound _flutterSound = FlutterSound();
  StreamSubscription<PlayStatus> _playerSubscription;

  _playPause() {
    if (!_isPlaying) {
      _play();
    } else {
      _pause();
    }
  }

  _play() async {
    // Copy Asset to file system
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String relativeSoundSampleDirectory = 'assets/sounds';
    String fullSoundSampleDirectory =
        '${documentsDirectory.path}/$relativeSoundSampleDirectory';
    String soundSamplePath = '$fullSoundSampleDirectory/sample.aac';

    if (FileSystemEntity.typeSync(soundSamplePath) ==
        FileSystemEntityType.notFound) {
      await Directory(fullSoundSampleDirectory).create(recursive: true);
      var sampleSoundAsset = await rootBundle.load('assets/sounds/sample.aac');
      final buffer = sampleSoundAsset.buffer;
      File(soundSamplePath).writeAsBytesSync(buffer.asUint8List(
          sampleSoundAsset.offsetInBytes, sampleSoundAsset.lengthInBytes));
    }

    String result = await _flutterSound.startPlayer(soundSamplePath);

    if (_playerSubscription == null) {
      _playerSubscription = _flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt());
          String txt = DateFormat('mm:ss:SS', 'en_ZA').format(date);
          this.setState(() {
            this._isPlaying = true;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          _progress,
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: (!_isPlaying ? Icon(Icons.play_arrow) : Icon(Icons.pause)),
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
