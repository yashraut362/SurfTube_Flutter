import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AudioSelector extends StatefulWidget {
  @override
  _AudioSelectorState createState() => _AudioSelectorState();
}

class _AudioSelectorState extends State<AudioSelector> {
  String selectedaudio;
  String downloadAudio = "";
  bool downloading = false;
  var progresstring = "";
  bool showLoading = false;

  Future<void> download() async {
    CircularProgressIndicator();
    Dio dio = Dio();
    try {
      var dir = await getExternalStorageDirectory();
      await dio.download(downloadAudio, "${dir.path}/raw.mp3",
          onReceiveProgress: (rec, total) {
        setState(() {
          downloading = true;
        });
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progresstring = "completed";
    });
    if (progresstring == "completed") {
      setState(() {
        showLoading = false;
      });
      Navigator.pop(context, selectedaudio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Center(child: Text("AudioSelector")),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showLoading = true;
                selectedaudio = "sample1.mp3";
                downloadAudio =
                    "https://firebasestorage.googleapis.com/v0/b/dcverse-c639f.appspot.com/o/sample1.mp3?alt=media&token=c7e084bb-7eff-4c97-9771-877b550278fa";
              });
              download();
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
                showLoading = true;
                selectedaudio = "sample2.mp3";
                downloadAudio =
                    "https://firebasestorage.googleapis.com/v0/b/dcverse-c639f.appspot.com/o/sample2.mp3?alt=media&token=7872a7fc-320b-40ab-8def-303751455e96";
              });
              download();
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
                showLoading = true;
                selectedaudio = "sample3.mp3";
                downloadAudio =
                    "https://firebasestorage.googleapis.com/v0/b/dcverse-c639f.appspot.com/o/sample3.mp3?alt=media&token=477cc39f-6ae2-4239-9ae7-f2874eeaccff";
              });
              download();
            },
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text('sample3.mp3'),
              subtitle: Text('Tap to select me'),
            ),
          ),
          SizedBox(
            height: 60,
          ),
          Text(' Internet Connection is Required',
              style: TextStyle(fontSize: 20.0)),
          SizedBox(
            height: 10,
          ),
          Builder(
            builder: (context) {
              if (showLoading == true) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                    Center(
                      child: Text(
                        "Please wait ",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Center(
                      child: Text(
                        " You will be automatically redirected",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ],
                );
              } else {
                return SizedBox(height: 1);
              }
            },
          ),
        ],
      ),
    );
  }
}
