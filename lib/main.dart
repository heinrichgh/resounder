import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resounder/models/sound_model.dart';
import 'package:resounder/widgets/new_sound_route.dart';
import 'package:resounder/widgets/sound_list.dart';

void main() {
  runApp(ChangeNotifierProvider(
    builder: (context) => SoundModel(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  openNewSoundRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewSoundRoute()),
    );
  }

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
//            child: SoundRecorder(),
            child: SoundList(),
          ),
          floatingActionButton: Builder(
              builder: (context) => FloatingActionButton(
                    onPressed: () {
                      openNewSoundRoute(context);
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.green,
                  )),
        ));
  }
}

