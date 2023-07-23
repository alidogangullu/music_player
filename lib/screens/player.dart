import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/src/widgets/image.dart' // ignore: implementation_imports
    as img;
import 'package:music_player/musicPlayer.dart';
import 'files.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 35, 10),
              child: Column(
                children: [
                  SizedBox(
                    width: 185,
                    height: 185,
                    child: ref.watch(musicPlayerProvider).isArtNull
                        ? Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(FluentIcons.music_note),
                            ),
                          )
                        : img.Image.memory(ref.watch(musicPlayerProvider).albumArt!),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                constraints: const BoxConstraints(minWidth: 195, maxWidth: 195),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.watch(musicPlayerProvider).songName),
                    Text(ref.watch(musicPlayerProvider).artistName),
                    Text(ref.watch(musicPlayerProvider).albumName),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Text(
                            ref.watch(musicPlayerProvider).pathAdded ? "${ref.watch(musicPlayerProvider).bitrate}kbps" : "",
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            ref.watch(musicPlayerProvider).pathAdded
                                ? "${ref.watch(musicPlayerProvider).bitsPerSample}Bit ${ref.watch(musicPlayerProvider).sampleRate}Hz"
                                : "",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Slider(
              label: ref.watch(musicPlayerProvider).isSeeking ? ref.watch(musicPlayerProvider).seek.toString().split('.').first : ref.watch(musicPlayerProvider).duration.toString().split('.').first,
              style: SliderThemeData(
                  labelBackgroundColor: Colors.grey,
              activeColor: ButtonState.all(ref.watch(musicPlayerProvider).themeColor)),
              value: ref.watch(musicPlayerProvider).isSeeking
                  ? ref.watch(musicPlayerProvider).seek.inMilliseconds.toDouble()
                  : ref.watch(musicPlayerProvider).position.inMilliseconds.toDouble(),
              onChangeStart: (double value) {
                ref.read(musicPlayerProvider).isSeeking = true;
              },
              onChangeEnd: (double value) async {
                ref.watch(musicPlayerProvider).player.seek(Duration(milliseconds: value.round()));
                ref.read(musicPlayerProvider).isSeeking = false;
              },
              min: 0,
              max: ref.watch(musicPlayerProvider).duration.inMilliseconds.ceilToDouble(),
              onChanged: (double value) {
                  ref.watch(musicPlayerProvider).seek = Duration(milliseconds: value.round());
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(FluentIcons.previous), onPressed: () {
                  ref.read(musicPlayerProvider.notifier).previous();
                }),
            ref.watch(musicPlayerProvider).isPlaying
                ? IconButton(
                    icon: const Icon(FluentIcons.pause), onPressed: (){
              ref.read(musicPlayerProvider.notifier).pause();
            })
                : IconButton(
                    icon: const Icon(FluentIcons.play_solid), onPressed: (){
              ref.read(musicPlayerProvider.notifier).play();
    }),
            IconButton(icon: const Icon(FluentIcons.next), onPressed: (){
              ref.read(musicPlayerProvider.notifier).next();
    }),
            IconButton(
              icon: const Icon(FluentIcons.playlist_music),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ContentDialog(
                      title: const Text("Music Files", style: TextStyle(fontSize: 18),),
                      content: ListView.builder(
                        itemCount: EditFiles.files.length,
                        itemBuilder: (BuildContext context, int index) {

                          return Card(
                            child: ListTile(
                              title: const SizedBox(height: 0,),
                              subtitle: Text(EditFiles.files[index].split(r'\').last),
                              leading: const Icon(FluentIcons.music_note),
                              trailing: IconButton(
                                onPressed: () {
                                    ref.watch(musicPlayerProvider).playingFilePath = EditFiles.files[index];

                                    ref.watch(musicPlayerProvider).player.open(
                                      Playlist(
                                        medias: [
                                          Media.file(File(ref.watch(musicPlayerProvider).playingFilePath)),
                                        ],
                                      ),
                                      autoStart: true,
                                    );

                                    ref.watch(musicPlayerProvider).isPlaying = true;
                                    ref.read(musicPlayerProvider.notifier).getMetadata();

                                    ref.watch(musicPlayerProvider).player.positionStream.listen((value) {
                                        ref.watch(musicPlayerProvider).position = value.position!;
                                        ref.watch(musicPlayerProvider).duration = value.duration!;
                                    });

                                    Navigator.of(context).pop();
                                },
                                icon: const Icon(FluentIcons.play),
                              ),
                            ),
                          );
                        },

                      ),
                      actions: [
                        Button(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
