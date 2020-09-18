import 'package:flutter/material.dart';
import 'package:surftube/screens/RecordScreen.dart';
import 'package:surftube/screens/WatchVideo.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('SurfTube'),
        ),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.camera), text: "RecordVideo"),
              Tab(icon: Icon(Icons.video_label), text: "WatchVideo")
            ],
          ),
        ),
        body: TabBarView(
          children: [RecordScreen(), WatchVideo()],
        ),
      ),
    );
  }
}
