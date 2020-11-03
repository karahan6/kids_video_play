import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:kidsvideoplay/models/channel.dart';
import 'package:kidsvideoplay/services/youtube_api.dart';
import 'package:kidsvideoplay/state/Model.dart';
import 'package:provider/provider.dart';

class AddChannelScreen extends StatefulWidget {
  @override
  AddChannelScreenState createState() => AddChannelScreenState();
}

class AddChannelScreenState extends State<StatefulWidget> {
  String selectedValue = "";

  @override
  void initState() {
    super.initState();
    context.read<Model>().removeAllSearchedChannels();
  }

  _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannelDetail(channelId: 'UCOmSDtCFlNiWknr4DwXIAKA');
  }

  GlobalKey<AutoCompleteTextFieldState<Channel>> key =
      new GlobalKey<AutoCompleteTextFieldState<Channel>>();

  AutoCompleteTextField<Channel> autoCompleteTextField;

  _buildVideoInfo(Channel channel, BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: new Text("Add Channel"),
          content: new Text(
              "Are you sure you want to add the channel named \"" +
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
            new FlatButton(
              child: Text('Add'),
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  context.read<Model>().addToChannels(channel.id);
                  int count = 0;
                  //Navigator.popUntil(context, (route) {
                  //  return count++ == 2;
                  //});
                  context.read<Model>().setSelectedIndex(1);
                  Navigator.pushNamed(context, '/');
                });
              },
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(2.0),
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
            Expanded(
              flex: 6,
              child: Container(
                child: Row(children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 23.0,
                    backgroundImage: NetworkImage(channel.profilePictureUrl),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
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
                    ),
                  ),
                ]),
              ),
            ),
            channel.added
                ? Expanded(
                    flex: 1,
                    child: IconButton(
                      iconSize: 32,
                      icon: Icon(Icons.check, color: Colors.green),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> items = new List<DropdownMenuItem>();
    items.add(DropdownMenuItem(child: Text("1"), value: 1));
    items.add(DropdownMenuItem(child: Text("2"), value: 2));

    autoCompleteTextField = new AutoCompleteTextField<Channel>(
      key: key,
      itemBuilder: (context, suggestion) => new Padding(
          child: _buildVideoInfo(suggestion, context),
          padding: EdgeInsets.all(4.0)),
      decoration: new InputDecoration(hintText: "Type at least three letters"),
      suggestions: Provider.of<Model>(context, listen: true).searchedChannels,
      //textChanged: (text) => {currentText = text},
      clearOnSubmit: true,
      textChanged: (text) => {
        if (text.length >= 3)
          {
            context.read<Model>().fetchChannels(text).then((value) => this
                .autoCompleteTextField
                .updateSuggestions(Provider.of<Model>(context, listen: false)
                    .searchedChannels))
          }
      },
      itemSorter: (a, b) =>
          a.title == b.title ? 0 : a.title.compareTo(b.title) > 0 ? 1 : -1,
      itemFilter: (suggestion, input) =>
          suggestion.title.toLowerCase().contains(input.toLowerCase()),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Channel"),
        ),
        body: Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: autoCompleteTextField));
  }
}
