
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resounder/data/sound.dart';
import 'package:resounder/models/sound_model.dart';
import 'package:resounder/widgets/sound_recorder.dart';

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
                    await Provider.of<SoundModel>(context).add(_sound);

                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('Sound Saved')));
                  }
                },
                child: Text("Save"),
              );
            },
          ),
          SoundRecorder()
        ]));
  }
}