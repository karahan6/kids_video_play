import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kidsvideoplay/state/Model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class VideoScreen extends StatefulWidget {
  final String id;

  VideoScreen({this.id});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor, name: "Video", context: context);
    context.read<Model>().setBlocked(true);
    final int _blockTime = context.read<Model>().blockTime.toInt() * 1000;
    Future.delayed(new Duration(milliseconds: _blockTime), () {
      context.read<Model>().setBlocked(false);
    });
    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName("Video");
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (context.read<Model>().blocked) {
      openMessage();
      return true;
    } else {
      Navigator.of(context).pop();
      return true;
    }
  }

  void onBackPressed() {
    if (context.read<Model>().blocked) {
      openMessage();
    } else {
      Navigator.of(context).pop();
    }
  }

  void openMessage() {
    Flushbar(
      backgroundColor: Colors.orange[500],
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      animationDuration: Duration(milliseconds: 2500),
      title: "Blocked",
      flushbarPosition: FlushbarPosition.TOP,
      message: "You have to wait " +
          context.read<Model>().blockTime.toInt().toString() +
          " seconds after the video page opens",
      duration: Duration(seconds: 3),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => onBackPressed(),
        ),
      ),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {
          print('Player is ready.');
        },
      ),
    );
  }
}
