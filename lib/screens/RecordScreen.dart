import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surftube/screens/AudioSelctor.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

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
  String _audioPath;
  String uncompressedOutput;
  String _finalpath;
  String _audio = "";
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  var uuid = Uuid();

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

  void showToast() {
    Toast.show(
        " Your video is Stored Here $_finalpath You can play video directly with play button in bottom",
        context,
        duration: 8,
        gravity: Toast.CENTER);
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
    return Center(
      child: Builder(
        builder: (context) {
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
          } else {
            return Column(
              children: [
                Text(
                  "Press start button to start recording ",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            );
          }
        },
      ),
    );
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

  void _onPlay() => OpenFile.open(_finalpath);

  Future<void> compress() async {
    final info = await VideoCompress.compressVideo(
      uncompressedOutput,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true,
    );
    _finalpath = info.path;
  }

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
    var directory = await getExternalStorageDirectory();
    _audioPath = directory.path + '/raw.mp3';
    File audiofile = File('$_audioPath');
    var outputuuid = uuid.v4();
    String outputfile = "${directory.path}/$outputuuid.mp4";
    _flutterFFmpeg
        .execute(
            "-i ${videofile.path} -i ${audiofile.path} -c copy -map 0:v:0 -map 1:a:0 -c:a aac -b:a 192k -shortest $outputfile")
        .then((rc) => print("FFmpeg process exited with rc $rc"));
    setState(() {
      uncompressedOutput = outputfile;
    });
    final status = await Permission.storage.request();
    if (uncompressedOutput != null) {
      if (status.isGranted) {
        showAlert(context);
      } else {
        Toast.show(
            "Sorry You need to provide permission for Further operations",
            context,
            duration: 5,
            gravity: Toast.TOP);
      }
    }
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 300,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Your Video is recording is Completed"),
              RaisedButton.icon(
                onPressed: () {
                  compress()
                      .then((value) => setState(() {
                            _audio = "";
                          }))
                      .then((value) =>
                          Navigator.of(context, rootNavigator: true).pop())
                      .then((value) => showToast());
                },
                icon: Icon(Icons.save),
                label: Text("Compress and Save"),
              ),
              RaisedButton.icon(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                icon: Icon(Icons.do_not_disturb),
                label: Text('Dont Save/ Retake'),
              ),
              Text('Please wait After Clicking Save !')
            ],
          ),
        ),
      ),
    );
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
          if (_audio == "") {
            return RaisedButton.icon(
              onPressed: () {
                moveToSecondPage();
              },
              icon: Icon(Icons.audiotrack),
              label: Text('Select Audio'),
            );
          } else if (_audio != "") {
            return Column(
              children: [
                new Center(
                  child: Text(
                    "Audio is Selected $_audio",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                new RaisedButton.icon(
                  onPressed: () {
                    moveToSecondPage();
                  },
                  icon: Icon(Icons.audiotrack),
                  label: Text('Change Audio'),
                ),
              ],
            );
          } else {
            return SizedBox();
          }
        }),
      ]),
    );
  }
}
