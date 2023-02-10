import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flac_metadata/flacstream.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:flutter/src/widgets/image.dart' // ignore: implementation_imports
    as img;
import 'package:mp3_info/mp3_info.dart';
import 'package:system_theme/system_theme.dart';
import 'files.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();
  late MP3Info mp3;

  String filePath = "";

  Duration duration = const Duration();
  Duration position = const Duration();
  Duration seek = const Duration();
  get durationText => duration.toString().split('.').first;
  get positionText => position.toString().split('.').first;
  get seekText => seek.toString().split('.').first;

  Uint8List? albumArt;
  bool isArtNull = true;
  String songName = "";
  String artistName = "";
  String albumName = "";
  int? bitrate, sampleRate, bitsPerSample;

  bool isPlaying = false;
  bool isSeeking = false;
  bool pathAdded = false;
  PlayerState playerState = PlayerState.stopped;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _audioPlayerStateSubscription;

  Future play() async {
    await player.play(DeviceFileSource(filePath));
    setState(() {
      isPlaying = true;
      playerState = PlayerState.playing;
    });
  }

  Future resume() async {
    if (pathAdded) {
      await player.resume();
      setState(() {
        isPlaying = true;
        playerState = PlayerState.playing;
      });
    }
  }

  Future pause() async {
    await player.pause();
    isPlaying = false;
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await player.stop();
    setState(() {
      isPlaying = false;
      playerState = PlayerState.stopped;
      position = const Duration();
    });
  }

  void next() {
    int index = EditFiles.files.indexOf(filePath);
    if (index + 1 <= EditFiles.files.length - 1) {
      filePath = EditFiles.files[index + 1];
      initFile();
    } else {
      filePath = EditFiles.files.first;
      initFile();
    }
  }

  void previous() {
    int index = EditFiles.files.indexOf(filePath);
    if (index - 1 >= 0) {
      filePath = EditFiles.files[index - 1];
      initFile();
    } else {
      filePath = EditFiles.files.last;
      initFile();
    }
  }

  Future<void> getMetadata() async {
    if (filePath.split(".").last == "mp3") {
      mp3 = MP3Processor.fromFile(File(filePath));
      sampleRate =
          int.parse(mp3.sampleRate.toString().split(".").last.split("_").last);
      bitrate = mp3.bitrate;
    } else if (filePath.split(".").last == "flac") {
      var metadata = await FlacInfo(File(filePath)).readMetadatas();
      sampleRate = int.parse(
          metadata.toString().split("sampleRate: ")[1].split(",").first);
      bitsPerSample = int.parse(
          metadata.toString().split("bitsPerSample: ")[1].split(",").first);
      bitrate = ((bitsPerSample! *
                  sampleRate! *
                  int.parse(metadata
                      .toString()
                      .split("channels: ")[1]
                      .split(",")
                      .first)) /
              1000)
          .round();
    }

    await MetadataGod.getMetadata(filePath).then((value) {
      albumArt = value!.picture!.data;
      albumName = value.album!;
      artistName = value.artist!;
      songName = value.title!;
    });
  }

  void initAudioPlayer() {
    _audioPlayerStateSubscription =
        player.onDurationChanged.listen((Duration d) {
      duration = d;
      _positionSubscription =
          player.onPositionChanged.listen((p) => setState(() {
                position = p;
                if (position >= duration) {
                  isPlaying = false;
                }
              }));
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        isPlaying = false;
        duration = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
    });
  }

  void initFile() {
    player.setSource(DeviceFileSource(filePath));
    getMetadata().whenComplete(() {
      if (albumArt != null) {
        setState(() {
          isArtNull = false;
        });
      }
      if (songName != "null" || albumName != "null" || artistName != "null") {
        setState(() {});
      }
      setState(() {
        play();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    if (EditFiles.files.isNotEmpty) {
      filePath = EditFiles.files.first;
      initFile();
      initAudioPlayer();
      pathAdded = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 35, 0),
              child: Column(
                children: [
                  SizedBox(
                    width: 185,
                    height: 185,
                    child: isArtNull
                        ? Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(FluentIcons.music_note),
                            ),
                          )
                        : img.Image.memory(albumArt!),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(songName),
                  Text(artistName),
                  Text(albumName),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text(
                          pathAdded ? "${bitrate}kbps" : "",
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          pathAdded
                              ? "${bitsPerSample}Bit ${sampleRate}Hz"
                              : "",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Slider(
              label: isSeeking ? seekText : positionText,
              style: SliderThemeData(
                  labelBackgroundColor: SystemTheme.accentColor.accent
                      .toAccentColor()), //change color to album art color
              value: isSeeking
                  ? seek.inMilliseconds.toDouble()
                  : position.inMilliseconds.toDouble(),
              onChangeStart: (double value) {
                isSeeking = true;
              },
              onChangeEnd: (double value) async {
                await player.seek(Duration(milliseconds: value.round()));
                isSeeking = false;
              },
              min: 0,
              max: duration.inMilliseconds.ceilToDouble(),
              onChanged: (double value) {
                setState(() {
                  seek = Duration(milliseconds: value.round());
                });
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(FluentIcons.previous), onPressed: previous),
            isPlaying
                ? IconButton(
                    icon: const Icon(FluentIcons.pause), onPressed: pause)
                : IconButton(
                    icon: const Icon(FluentIcons.play_solid),
                    onPressed: resume),
            IconButton(icon: const Icon(FluentIcons.next), onPressed: next),
          ],
        ),
      ],
    );
  }
}
