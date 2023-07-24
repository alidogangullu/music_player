import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_folder_picker/flutter_desktop_folder_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/musicPlayer.dart';

class EditFiles extends ConsumerStatefulWidget {
  const EditFiles({Key? key}) : super(key: key);
  static List<String> files = [];

  @override
  ConsumerState createState() => _EditFilesState();
}

class _EditFilesState extends ConsumerState<EditFiles> {
  Future<List<String>> getFilePaths(String directory) async {
    final dir = Directory(directory);
    final List<String> filePaths = [];
    if (await dir.exists()) {
      final Stream<FileSystemEntity> files =
          dir.list(recursive: true, followLinks: false);
      await for (var file in files) {
        if (FileSystemEntity.isFileSync(file.path)) {
          if (file.path.endsWith("flac") || file.path.endsWith("mp3")) {
            filePaths.add(file.path);
          }
        }
      }
    }
    return filePaths;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Button(
              onPressed: () async {
                String? path =
                    await FlutterDesktopFolderPicker.openFolderPickerDialog();
                EditFiles.files = await getFilePaths(path!);
                setState(() { });
              },
              child: const Text("Select Music Folder"),
            ),
          ),
          if (EditFiles.files.isNotEmpty)
          Expanded(
            child: ListView.builder(
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
                      },
                      icon: const Icon(FluentIcons.play),
                    ),
                  ),
                );
              },

            ),
          ),
        ],
      ),
    );
  }
}
