import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kidsvideoplay/screens/channels.dart';
import 'package:kidsvideoplay/screens/colorPicker.dart';
import 'package:kidsvideoplay/screens/home.dart';
import 'package:kidsvideoplay/screens/settings.dart';
import 'package:kidsvideoplay/state/Model.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<StatefulWidget> {
  //int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ChannelsScreen(),
    SettingsScreen(),
  ];

  _onItemTapped(int index) {
    if (context.read<Model>().blocked) {
      Flushbar(
        backgroundColor: Colors.lightGreen,
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
    } else {
      context.read<Model>().setSelectedIndex(index);
      //setState(() {
      //  _selectedIndex = index;
      //});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //context.read<Model>().changeTitle("Videos");
  }

  static const buttomNavItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text('Home'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.subscriptions),
      title: Text('Channels'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      title: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = context.watch<Model>().selectedIndex;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: buttomNavItems[_selectedIndex].title,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: buttomNavItems,
        currentIndex: _selectedIndex,
        selectedItemColor: context.watch<Model>().color,
        onTap: _onItemTapped,
      ),
    );
  }
}
