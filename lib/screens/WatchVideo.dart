import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:surftube/constants/data_json.dart';
import 'package:surftube/services/surfvideoplayer.dart';

class WatchVideo extends StatefulWidget {
  @override
  _WatchVideoState createState() => _WatchVideoState();
}

class _WatchVideoState extends State<WatchVideo>
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
    //  print(items.length);
    return RotatedBox(
      quarterTurns: 1,
      child: TabBarView(
        controller: _tabController,
        children: List.generate(
          items.length,
          (index) {
            return PreloadPageView(
              preloadPagesCount: items.length,
              children: [
                RotatedBox(
                  quarterTurns: -1,
                  child: SurfvideoPlayer(
                    videoUrl: items[index]['videoUrl'],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
