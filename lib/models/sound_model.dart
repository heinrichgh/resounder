import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:resounder/data/sound.dart';

class SoundModel extends ChangeNotifier {
  final List<Sound> _soundItems = [];

  UnmodifiableListView<Sound> get soundItems =>
      UnmodifiableListView(_soundItems);

  SoundModel() {
    init();
  }

  init() async {
    _soundItems.clear();
    await SoundProvider.open();
    var soundItems = await SoundProvider.queryAll();
    for (var soundItem in soundItems) {
      _soundItems.add(soundItem);
    }

    notifyListeners();
  }

  add(Sound sound) async {
    var savedSound = await SoundProvider.insert(sound);
    _soundItems.add(savedSound);
    notifyListeners();
  }
}
