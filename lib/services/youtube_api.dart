import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:kidsvideoplay/models/channel.dart';
import 'package:kidsvideoplay/models/video.dart';
import 'package:kidsvideoplay/utilities/keys.dart';

class APIService {
  APIService._instantiate();

  static final APIService instance = APIService._instantiate();

  final String _baseUrl = 'www.googleapis.com';
  Map<String, String> videosNextPageTokens = new Map<String, String>();
  String _nextPageToken = '';
  String _channelsNextPageToken = '';

  //get channels by using a query string (search api, type is channel)
  //https://developers.google.com/youtube/v3/docs/search/list
  Future<List<Channel>> fetchChannels({String searchQuery}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'key': API_KEY,
      'type': 'channel',
      'pageToken': _channelsNextPageToken,
      'q': searchQuery
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/search',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _channelsNextPageToken = data['nextPageToken'] ?? '';
      List<dynamic> listOfChannels = data['items'];
      List<Channel> channels = new List<Channel>();
      Map<String, dynamic> channelMap;
      for (var channel in listOfChannels) {
        channelMap = Map.from(channel);
        channels.add(Channel.fromChannelToChannelInfo(channelMap));
      }

      return channels;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  Future<Channel> fetchChannelDetail({String channelId}) async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'id': channelId,
      'key': API_KEY,
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['items'][0];
      Channel channel = Channel.fromMap(data);

      // Fetch first batch of videos from uploads playlist
      channel.videos = await fetchVideosFromChannel(
        channelId: channelId,
      );
      return channel;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  String convertDuration({String durationString}) {
    String result = "";
    RegExp iReg = RegExp(r'(\d+)');
    List<String> numbers =
        iReg.allMatches(durationString).map((m) => m.group(0)).toList();
    numbers.forEach((number) => {result = result + number + ":"});
    return result.substring(0, result.length - 1);
  }

  //get videos from a channel by channel id (search api, type is video)
  //https://developers.google.com/youtube/v3/docs/search/list
  Future<List<Video>> fetchVideosFromChannel({String channelId}) async {
    Map<String, String> parameters = {
      'part': 'snippet,id',
      'channelId': channelId,
      'maxResults': '10',
      'pageToken': videosNextPageTokens[channelId] ?? '',
      'key': API_KEY,
      'type': 'video'
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/search',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Playlist Videos
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      videosNextPageTokens[channelId] = data['nextPageToken'] ?? '';
      List<dynamic> videosJson = data['items'];
      String videoIds = "";
      videosJson.forEach(
        (item) => videoIds = videoIds + item['id']['videoId'] + ",",
      );
      videoIds = videosJson.length > 0
          ? videoIds.substring(0, videoIds.length - 1)
          : videoIds;
      List<dynamic> videoInfo = await getDetailOfVideos(videoIds: videoIds);
      String id;
      dynamic video;
      videosJson.forEach((vj) => {
            id = vj['id']['videoId'],
            video = videoInfo.firstWhere((vd) => vd['id'] == id),
            vj['snippet']['videoId'] = id,
            vj['snippet']['duration'] = convertDuration(
                durationString: video['contentDetails']['duration']),
            vj['snippet']['channelTitle'] = video['snippet']['channelTitle'],
            vj['snippet']['viewCount'] = video['statistics']['viewCount'],
          });
      List<Video> videos = [];
      videosJson.forEach(
        (json) => videos.add(
          Video.fromMap(json['snippet']),
        ),
      );
      return videos;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  //get details of videos such as duration (snippet, contentDetails, statistics)
  //https://developers.google.com/youtube/v3/docs/videos/list
  Future<List<dynamic>> getDetailOfVideos({String videoIds}) async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'id': videoIds,
      'key': API_KEY,
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/videos',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['items'];

      return data;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }
}
