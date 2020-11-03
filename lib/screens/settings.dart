import 'package:flutter/material.dart';
import 'package:kidsvideoplay/state/Model.dart';
import 'package:provider/provider.dart';
import 'colorPicker.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<StatefulWidget> {
  double _currentSliderValue = 10;
  bool isSliderOpen = false;

  @override
  void initState() {
    super.initState();
    //context.read<Model>().changeTitle("Channels");
  }

  List<String> listItems = ["Application Color", "Block Time"];
  List<IconData> listItemsLeadingIcons = [Icons.color_lens, Icons.lock_open];
  List<Widget> listItemOnTaps = [ColorPicker(), null];
  @override
  Widget build(BuildContext context) {
    double _blockTime = context.watch<Model>().blockTime;
    return Scaffold(
        body: Column(
      children: [
        Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: listItems.length,
            itemBuilder: (BuildContext context, int index) {
              return new Card(
                elevation: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: ListTile(
                      onTap: () => {
                        if (index == 0)
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ColorPicker(),
                              ),
                            )
                          }
                        else
                          {
                            setState(() {
                              isSliderOpen = !isSliderOpen;
                            })
                          }
                      },
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
                      leading: Container(
                        padding: EdgeInsets.only(right: 12.0),
                        child: IconButton(
                          icon: Icon(listItemsLeadingIcons[index]),
                          color: const Color(0xFFE27023),
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.only(right: 4.0),
                        child: IconButton(
                          icon: index == 0
                              ? Icon(Icons.arrow_forward_ios)
                              : (isSliderOpen
                                  ? Icon(Icons.arrow_downward)
                                  : Icon(Icons.arrow_forward_ios)),
                          color: const Color(0xFFE27023),
                        ),
                      ),
                      title: Text(
                        listItems[index],
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )),
              );
            },
          ),
        ),
        Card(
          child: isSliderOpen
              ? Column(
                  children: [
                    Slider(
                      value: _blockTime,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: _blockTime.round().toString(),
                      onChanged: (double value) {
                        context.read<Model>().setBlockTime(value);
                      },
                    ),
                    Container(
                      margin: EdgeInsets.all(5),
                      child: Text(
                        _blockTime.toInt().toString() + " Seconds",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              : null,
        )
      ],
    ));
  }
}
