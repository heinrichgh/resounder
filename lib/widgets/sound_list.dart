import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resounder/data/sound.dart';
import 'package:resounder/models/sound_model.dart';

class SoundList extends StatefulWidget {
  @override
  _SoundListState createState() => _SoundListState();
}

class _SoundListState extends State<SoundList> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildSoundList() {
    return Consumer<SoundModel>(
      builder: (context, soundModel, child) {
        return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: soundModel.soundItems.length,
            itemBuilder: (context, i) {
              return _buildSoundRow(soundModel.soundItems[i]);
            });
      },
    );
  }

  Widget _buildSoundRow(Sound sound) {
    return Column(
      children: <Widget>[
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
      child: _buildSoundList(),
    );
  }
}