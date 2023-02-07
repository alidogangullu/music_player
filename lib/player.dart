import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flac_metadata/flacstream.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:flutter/src/widgets/image.dart' // ignore: implementation_imports
    as img;
import 'package:mp3_info/mp3_info.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();
  late MP3Info mp3;

  String filePath = "null";

  Uint8List? albumArt;
  String songName = "null";
  String artistName = "null";
  String albumName = "null";
  int? bitrate;
  String? sampleRate;
  bool isArtNull = true;

  Future<void> getMetadata() async {
    if (filePath.split(".").last == "mp3"){
      mp3 = MP3Processor.fromFile(File(filePath));
      sampleRate = mp3.sampleRate.toString().split(".").last.split("_").last;
      bitrate = mp3.bitrate;
    }
    else if(filePath.split(".").last == "flac"){
      var metadatas = await FlacInfo(File(filePath)).readMetadatas();
      sampleRate = metadatas.toString().split("sampleRate: ")[1].split(",").first;

      //bitrate = metadatas;
    }

    await MetadataGod.getMetadata(filePath).then((value) {
      albumArt = value!.picture!.data;
      albumName = value.album!;
      artistName = value.artist!;
      songName = value.title!;
    });
  }

  @override
  void initState() {
    filePath = "C:/Users/alido/Downloads/test.flac";
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
    });
    super.initState();
  }

  double value = 0;
  bool disabled = false;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 200,
            height: 200,
            child: isArtNull
                ? Container(
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(FluentIcons.music_note),
                    ),
                  )
                : img.Image.memory(albumArt!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(songName),
              Text(artistName),
              Text(albumName),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Slider(
                  label: value.floor().toString(),
                  style: SliderThemeData(labelBackgroundColor: Colors.blue),
                  //SystemTheme.accentColor.accent.toAccentColor()
                  value: value,
                  onChanged: disabled ? null : (v) => setState(() => value = v),
                ),
              ),
              isPlaying
                  ? IconButton(
                      icon: const Icon(FluentIcons.pause),
                      onPressed: () async {
                        await player.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(FluentIcons.play_solid),
                      onPressed: () async {
                        await player.resume();
                        setState(() {
                          isPlaying = true;
                        });
                      },
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Text("Bitrate: $bitrate", style: const TextStyle(fontSize: 12),),
                    const SizedBox(width: 10,),
                    Text("Samplerate: ${sampleRate}", style: const TextStyle(fontSize: 12),),
                  ],
                ),
              )
            ],
          ),
        ),

      ],
    );
  }
}
