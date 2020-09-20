import 'package:flutter/material.dart';

class AudioSelector extends StatefulWidget {
  @override
  _AudioSelectorState createState() => _AudioSelectorState();
}

class _AudioSelectorState extends State<AudioSelector> {
  String selectedaudio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AudioSelector"),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                selectedaudio = "sample1.mp3";
              });
              Navigator.pop(context, selectedaudio);
            },
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text('sample1.mp3'),
              subtitle: Text('Tap to select me'),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                selectedaudio = "sample2.mp3";
              });
              Navigator.pop(context, selectedaudio);
            },
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text('sample2.mp3'),
              subtitle: Text('Tap to select me'),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                selectedaudio = "sample3.mp3";
              });
              Navigator.pop(context, selectedaudio);
            },
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text('sample3.mp3'),
              subtitle: Text('Tap to select me'),
            ),
          ),
        ],
      ),
    );
  }
}
