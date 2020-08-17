import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SurfvideoPlayer extends StatefulWidget {
  final String videoUrl;
  SurfvideoPlayer({this.videoUrl});
  @override
  _SurfvideoPlayerState createState() => _SurfvideoPlayerState();
}

class _SurfvideoPlayerState extends State<SurfvideoPlayer> {
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl.toString()),
      flags: const YoutubePlayerFlags(
        //made changes in package toggling this wont work
        hideControls: true,
        hideThumbnail: false,
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: true,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 9 / 16,
          showVideoProgressIndicator: false,
        ),
      ),
    );
  }
}
