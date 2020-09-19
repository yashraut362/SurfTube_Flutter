import 'package:flutter/material.dart';

class AudioSelector extends StatelessWidget {
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
              Navigator.pop(context, "sample1.mp3");
            },
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text('sample1.mp3'),
              subtitle: Text('Tap to select me'),
            ),
          ),
          InkWell(
            onTap: () {},
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text('sample2.mp3'),
              subtitle: Text('Tap to select me'),
            ),
          ),
          InkWell(
            onTap: () {},
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text('sample2.mp3'),
              subtitle: Text('Tap to select me'),
            ),
          ),
        ],
      ),
    );
  }
}
