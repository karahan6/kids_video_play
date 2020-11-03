import 'package:flutter/material.dart';
import 'package:kidsvideoplay/models/channel.dart';
import 'package:kidsvideoplay/screens/addChannel.dart';
import 'package:kidsvideoplay/state/Model.dart';
import 'package:provider/provider.dart';

class ChannelsScreen extends StatefulWidget {
  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
    //context.read<Model>().changeTitle("Channels");
  }

  _buildVideoInfo(Channel channel) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
      padding: EdgeInsets.all(2.0),
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              child: Container(
                  child: Row(children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 23.0,
              backgroundImage: NetworkImage(channel.profilePictureUrl),
            ),
            SizedBox(width: 10.0),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    channel.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ]))),
          Container(
            child: IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: new Text("Remove Channel"),
                        content: new Text(
                            "Are you sure you want to remove the channel named \"" +
                                channel.title +
                                "\""),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          new FlatButton(
                            child: new Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('Remove'),
                            onPressed: () {
                              context
                                  .read<Model>()
                                  .removeFromChannel(channel.id);

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )),
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Channel> channels = context.watch<Model>().channels;
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: channels.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildVideoInfo(channels[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.watch<Model>().color,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddChannelScreen(),
          ),
        ),
        tooltip: "Add Channel",
        child: Icon(Icons.add),
      ),
    );
  }
}
