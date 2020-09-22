import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surftube/screens/AudioSelctor.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';

class RecordScreen extends StatefulWidget {
  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  List<CameraDescription> _cameras;
  CameraController _controller;
  int _cameraIndex;
  bool _isRecording = false;
  String _filePath;
  String _toastPath;
  String _playpath;
  String _audioPath;
  final _flutterVideoCompress = FlutterVideoCompress();
  String _audio = "No Audio selected";
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  var uuid = Uuid();
  String uncompressedOutput;

  @override
  void initState() {
    super.initState();

    availableCameras().then((cameras) {
      _cameras = cameras;
      if (_cameras.length != 0) {
        _cameraIndex = 0;
        _initCamera(_cameras[_cameraIndex]);
      }
    });
  }

//turn this enableaudio flag to false on deployment
  _initCamera(CameraDescription camera) async {
    if (_controller != null) await _controller.dispose();
    _controller =
        CameraController(camera, ResolutionPreset.high, enableAudio: false);
    _controller.addListener(() => this.setState(() {}));
    _controller.initialize();
  }

  Widget _counter() {
    return Center(child: Builder(builder: (context) {
      if (_isRecording == true) {
        return Countdown(
          seconds: 30,
          build: (BuildContext context, double time) => Text(
            time.toString(),
            style: TextStyle(color: Colors.white),
          ),
          onFinished: () {
            _onStop();
          },
        );
      } else if (_flutterVideoCompress.isCompressing == true) {
        return Text(
          "Please wait Your Video is Compressing ! You will be able to Play video after Compressing",
          style: TextStyle(color: Colors.white),
        );
      } else {
        return Text(
          "Press start button to start recording $_audio",
          style: TextStyle(color: Colors.white),
        );
      }
    }));
  }

  Widget _buildCamera() {
    if (_controller == null || !_controller.value.isInitialized)
      return Center(child: Text('Loading...'));
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: CameraPreview(_controller),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            _getCameraIcon(_cameras[_cameraIndex].lensDirection),
            color: Colors.white,
          ),
          onPressed: _onSwitchCamera,
        ),
        IconButton(
          icon: Icon(
            Icons.radio_button_checked,
            color: Colors.white,
          ),
          onPressed: _isRecording ? null : _onRecord,
        ),
        IconButton(
          icon: Icon(
            Icons.stop,
            color: Colors.white,
          ),
          onPressed: _isRecording ? _onStop : null,
        ),
        IconButton(
          icon: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: _isRecording ? null : _onPlay,
        ),
      ],
    );
  }

  void updateInformation(String audio) {
    setState(() => _audio = audio);
  }

  void moveToSecondPage() async {
    final audio = await Navigator.push(
      context,
      CupertinoPageRoute(
          fullscreenDialog: true, builder: (context) => AudioSelector()),
    );
    updateInformation(audio);
  }

  void _onPlay() => OpenFile.open(uncompressedOutput);

  // void showToast() {
  //   Toast.show(_toastPath, context, duration: 8, gravity: Toast.CENTER);
  // }

  // Future<void> _videocompress() async {
  //   final info = await _flutterVideoCompress.compressVideo(
  //     uncompressedOutput,
  //     quality:
  //         VideoQuality.MediumQuality, // default(VideoQuality.DefaultQuality)
  //     deleteOrigin: true, // default(false)
  //   );
  //   String storagepath = info.path;
  //   setState(() {
  //     _toastPath =
  //         "Your Video is stored at $storagepath You can play this video after This Toast";
  //     _playpath = storagepath;
  //   });
  //   // showToast();
  // }

  Future<void> _onStop() async {
    assetsAudioPlayer.stop();
    await _controller.stopVideoRecording();
    setState(() => _isRecording = false);
    addExternalAudio();
  }

  Future<void> _onRecord() async {
    assetsAudioPlayer.open(Audio("assets/$_audio"));
    var directory = await getTemporaryDirectory();
    print(directory.path + "Data is Stored here Yash");
    var tempuuid = uuid.v4();
    _filePath = directory.path + '/$tempuuid.mp4';
    _controller.startVideoRecording(_filePath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> addExternalAudio() async {
    File videofile = File('$_filePath');
    print('${videofile.path} , this is video path jolly');

    var directory = await getExternalStorageDirectory();
    _audioPath = directory.path + '/raw.mp3';

    File audiofile = File('$_audioPath');
    print('${audiofile.path} , this is audio path jolly');

    var outputuuid = uuid.v4();
    String outputfile = "${directory.path}/$outputuuid.mp4";
    _flutterFFmpeg
        .execute(
            "-i ${videofile.path} -i ${audiofile.path} -c copy -map 0:v:0 -map 1:a:0 -c:a aac -b:a 192k -shortest $outputfile")
        .then((rc) => print("FFmpeg process exited with rc $rc"));

    setState(() {
      uncompressedOutput = outputfile;
    });
    debugPrint("video audioedit is done $uncompressedOutput");
    // _videocompress();
  }

  IconData _getCameraIcon(CameraLensDirection lensDirection) {
    return lensDirection == CameraLensDirection.back
        ? Icons.camera_front
        : Icons.camera_rear;
  }

  void _onSwitchCamera() {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % 2;
    _initCamera(_cameras[_cameraIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      //  appBar: AppBar(title: Text('SurfVideo Recorder')),
      body: Column(children: [
        Expanded(
          child: Center(
            child: _buildCamera(),
          ),
        ),
        _buildControls(),
        _counter(),
        Builder(builder: (context) {
          if (_audio == "No Audio selected") {
            return RaisedButton.icon(
              onPressed: () {
                moveToSecondPage();
              },
              icon: Icon(Icons.audiotrack),
              label: Text('Select Audio'),
            );
          } else {
            return Center(
              child: Text("Audio is Selected $_audio"),
            );
          }
        }),
      ]),
    );
  }
}
