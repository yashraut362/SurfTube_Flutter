import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:toast/toast.dart';

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
  final _flutterVideoCompress = FlutterVideoCompress();

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

  _initCamera(CameraDescription camera) async {
    if (_controller != null) await _controller.dispose();
    _controller = CameraController(camera, ResolutionPreset.medium);
    _controller.addListener(() => this.setState(() {}));
    _controller.initialize();
  }

  Widget _counter() {
    return Center(child: Builder(builder: (context) {
      if (_isRecording == true) {
        return Countdown(
          seconds: 30,
          build: (BuildContext context, double time) => Text(time.toString()),
          onFinished: () {
            _onStop();
          },
        );
      } else if (_flutterVideoCompress.isCompressing == true) {
        return Text(
            "Please wait Your Video is Compressing ! You will be able to Play video after Compressing");
      } else {
        return Text("Press start button to start recording");
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
          icon: Icon(_getCameraIcon(_cameras[_cameraIndex].lensDirection)),
          onPressed: _onSwitchCamera,
        ),
        IconButton(
          icon: Icon(Icons.radio_button_checked),
          onPressed: _isRecording ? null : _onRecord,
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: _isRecording ? _onStop : null,
        ),
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: _isRecording ? null : _onPlay,
        ),
      ],
    );
  }

  void _onPlay() => OpenFile.open(_playpath);

  void showToast() {
    Toast.show(_toastPath, context, duration: 8, gravity: Toast.CENTER);
  }

  Future<void> _videocompress() async {
    final info = await _flutterVideoCompress.compressVideo(
      _filePath,
      quality:
          VideoQuality.MediumQuality, // default(VideoQuality.DefaultQuality)
      deleteOrigin: true, // default(false)
    );
    String storagepath = info.path;
    setState(() {
      _toastPath = "Your Video is stored at $storagepath";
      _playpath = storagepath;
    });
    showToast();
  }

  Future<void> _onStop() async {
    await _controller.stopVideoRecording();
    setState(() => _isRecording = false);
    _videocompress();
  }

  Future<void> _onRecord() async {
    var directory = await getExternalStorageDirectory();
    print(directory.path + "Data is Stored here Yash");
    _filePath = directory.path + '/${DateTime.now()}.mp4';
    _controller.startVideoRecording(_filePath);
    setState(() {
      _isRecording = true;
    });
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
      //  appBar: AppBar(title: Text('SurfVideo Recorder')),
      body: Column(children: [
        Container(height: 600, child: Center(child: _buildCamera())),
        _buildControls(),
        _counter(),
      ]),
    );
  }
}
