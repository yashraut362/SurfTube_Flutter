import 'package:flutter/material.dart';
import 'package:surftube/constants/data_json.dart';
import 'package:surftube/services/surfvideoplayer.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: items.length, vsync: this);
  }

  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: TabBarView(
        controller: _tabController,
        children: List.generate(items.length, (index) {
          return RotatedBox(
              quarterTurns: -1,
              child: SurfvideoPlayer(
                videoUrl: items[index]['videoUrl'],
              ));
        }),
      ),
    );
  }
}
