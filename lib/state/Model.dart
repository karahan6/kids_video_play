import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kidsvideoplay/models/channel.dart';
import 'package:kidsvideoplay/services/youtube_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

//agnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
class Model with ChangeNotifier, DiagnosticableTreeMixin {
  Model() {
    SharedPreferences.getInstance().then((prfs) => {
          prefs = prfs,
          setChannels(prefs.getStringList('_channels')),
          _color = prefs.getInt('_color') != null
              ? generateMaterialColor(Color(prefs.getInt('_color')))
              : Colors.red,
          _blockTime = prefs.getDouble('_blockTime') ?? 10,
          notifyListeners()
        });
  }
  SharedPreferences prefs;
  List<Channel> _searchedChannels = new List<Channel>();
  List<Channel> _channels = new List<Channel>();
  int _selectedIndex = 1;
  String _title = "Videos";
  MaterialColor _color = Colors.red;
  double _blockTime = 10;
  bool _blocked = false;

  List<Channel> get searchedChannels => _searchedChannels;
  List<Channel> get channels => _channels;
  String get title => _title;
  Color get color => _color;
  double get blockTime => _blockTime;
  bool get blocked => _blocked;
  int get selectedIndex => _selectedIndex;

  void setChannels(List<String> channelIds) async {
    List<Channel> channelList = new List<Channel>();

    for (int i = 0; i < channelIds.length; i++) {
      Channel channelWithDetail = await APIService.instance
          .fetchChannelDetail(channelId: channelIds[i]);
      channelList.add(channelWithDetail);
    }
    _channels = channelList;
    notifyListeners();
  }

  void setSelectedIndex(int selected) {
    _selectedIndex = selected;
    notifyListeners();
  }

  void setBlocked(bool blocked) {
    _blocked = blocked;
    notifyListeners();
  }

  void setBlockTime(double blockTime) {
    _blockTime = blockTime;
    prefs.setDouble('_blockTime', blockTime);
    notifyListeners();
  }

  void changeTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void changeColor(Color color) {
    int colorInt = color.value;
    _color = generateMaterialColor(color);
    prefs.setInt('_color', colorInt);
    notifyListeners();
  }

  Future<void> addToChannels(String channelId) async {
    Channel channelWithDetail =
        await APIService.instance.fetchChannelDetail(channelId: channelId);
    _channels.add(channelWithDetail);
    _searchedChannels.firstWhere((element) => element.id == channelId).added =
        true;
    List<String> channelList =
        prefs.getStringList('_channels') ?? new List<String>();
    channelList.add(channelId);
    prefs.setStringList('_channels', channelList);
    notifyListeners();
  }

  void removeFromChannel(String id) {
    Channel channelToRemove =
        channels.firstWhere((element) => element.id == id);
    _channels.remove(channelToRemove);
    List<String> channelList = prefs.getStringList('_channels');
    if (channelList != null && channelList.contains(id)) {
      channelList.remove(id);
      prefs.setStringList('_channels', channelList);
    }
    notifyListeners();
  }

  Future<void> fetchChannels(String search) async {
    List<Channel> _channelsLoaded =
        await APIService.instance.fetchChannels(searchQuery: search);
    List<String> channelsIds = _channels.map((e) => e.id).toList();
    _channelsLoaded.forEach((ch) {
      ch.added = channelsIds.contains(ch.id);
    });
    _searchedChannels = _channelsLoaded;
    notifyListeners();
  }

  void removeAllSearchedChannels() {
    _searchedChannels = new List<Channel>();
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('searchedChannels', _searchedChannels));
    properties.add(IterableProperty('channels', _channels));
  }

  MaterialColor generateMaterialColor(Color color) {
    return MaterialColor(color.value, {
      50: tintColor(color, 0.9),
      100: tintColor(color, 0.8),
      200: tintColor(color, 0.6),
      300: tintColor(color, 0.4),
      400: tintColor(color, 0.2),
      500: color,
      600: shadeColor(color, 0.1),
      700: shadeColor(color, 0.2),
      800: shadeColor(color, 0.3),
      900: shadeColor(color, 0.4),
    });
  }

  int tintValue(int value, double factor) =>
      max(0, min((value + ((255 - value) * factor)).round(), 255));

  Color tintColor(Color color, double factor) => Color.fromRGBO(
      tintValue(color.red, factor),
      tintValue(color.green, factor),
      tintValue(color.blue, factor),
      1);

  int shadeValue(int value, double factor) =>
      max(0, min(value - (value * factor).round(), 255));

  Color shadeColor(Color color, double factor) => Color.fromRGBO(
      shadeValue(color.red, factor),
      shadeValue(color.green, factor),
      shadeValue(color.blue, factor),
      1);
}
