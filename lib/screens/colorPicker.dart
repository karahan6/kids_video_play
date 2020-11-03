import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:kidsvideoplay/state/Model.dart';
import 'package:provider/provider.dart';

class ColorPicker extends StatefulWidget {
  @override
  ColorPickerState createState() => ColorPickerState();
}

class ColorPickerState extends State<StatefulWidget> {
  //Color _currentColor = Colors.blue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.watch<Model>().color,
        title: const Text('Circle color picker sample'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: CircleColorPicker(
                initialColor: context.watch<Model>().color,
                onChanged: (Color color) => _onColorChanged(color, context),
                colorCodeBuilder: (context, color) {
                  return Text(
                    'rgb(${color.red}, ${color.green}, ${color.blue})',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onColorChanged(Color color, BuildContext context) {
    context.read<Model>().changeColor(color);
    //setState(() => _currentColor = color);
  }
}
