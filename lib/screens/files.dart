import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_folder_picker/flutter_desktop_folder_picker.dart';

class EditFiles extends StatefulWidget {
  const EditFiles({Key? key}) : super(key: key);
  static List<String> files = [];

  @override
  State<EditFiles> createState() => _EditFilesState();
}

class _EditFilesState extends State<EditFiles> {
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
      child: Button(
        onPressed: () async {
          String? path =
              await FlutterDesktopFolderPicker.openFolderPickerDialog();
          EditFiles.files = await getFilePaths(path!);
        },
        child: const Text("Select Music Folder"),
      ),
    );
  }
}
