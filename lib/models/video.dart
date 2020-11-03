class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String duration;

  Video({
    this.id,
    this.title,
    this.thumbnailUrl,
    this.channelTitle,
    this.duration,
  });

  factory Video.fromMap(Map<String, dynamic> snippet) {
    return Video(
        id: snippet['videoId'],
        title: snippet['title'],
        thumbnailUrl: snippet['thumbnails']['high']['url'],
        channelTitle: snippet['channelTitle'],
        duration: snippet['duration']);
  }
}
