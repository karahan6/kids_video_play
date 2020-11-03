import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:kidsvideoplay/models/channel.dart';
import 'package:kidsvideoplay/models/video.dart';
import 'package:kidsvideoplay/screens/video.dart';
import 'package:kidsvideoplay/services/youtube_api.dart';
import 'package:kidsvideoplay/state/Model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<StatefulWidget> {
  Channel _channel;
  List<Video> _videos = new List<Video>();
  List<String> _channelIdList;
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  _initChannel() async {
    List<String> channelIdList = new List<String>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      context
          .read<Model>()
          .channels
          .forEach((element) => channelIdList.add(element.id));

      List<Video> videos = new List<Video>();

      for (var channelId in channelIdList) {
        var addVideos = await APIService.instance
            .fetchVideosFromChannel(channelId: channelId);
        videos.addAll(addVideos);
      }
      videos.shuffle();
      setState(() {
        _videos = videos;
        _channelIdList = channelIdList;
      });
    });
  }

  _buildProfileInfo() {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      height: 100.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 35.0,
            backgroundImage: NetworkImage(_channel.profilePictureUrl),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _channel.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_channel.subscriberCount} subscribers',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildVideo(Video video) {
    var unescape = new HtmlUnescape();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(id: video.id),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        height: 260.0,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(video.thumbnailUrl),
                  height: MediaQuery.of(context).size.width * 0.47,
                  width: MediaQuery.of(context).size.width,
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(video.duration,
                          style: TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.black)),
                    )),
              ],
            ),
            SizedBox(height: 5.0),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  unescape.convert(video.title),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadMoreVideos() async {
    _isLoading = true;

    List<Video> videos = new List<Video>();
    for (var channelId in _channelIdList) {
      var addVideos = await APIService.instance
          .fetchVideosFromChannel(channelId: channelId);
      videos.addAll(addVideos);
    }
    videos.shuffle();
    setState(() {
      _videos.addAll(videos);
    });

    _isLoading = false;
  }

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoading != true
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollDetails) {
                if (!_isLoading &&
                    //_channel.videos.length != int.parse(_channel.videoCount) &&
                    scrollDetails.metrics.pixels ==
                        scrollDetails.metrics.maxScrollExtent) {
                  _loadMoreVideos();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _videos.length,
                itemBuilder: (BuildContext context, int index) {
                  Video video = _videos[index];
                  return _buildVideo(video);
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor, // Red
                ),
              ),
            ),
    );
  }
}
