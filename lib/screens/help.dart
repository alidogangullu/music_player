import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:music_player/main.dart';
import 'package:path_provider/path_provider.dart';
import '../application.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  bool isDownloading = false;
  double downloadProgress = 0;
  String downloadedFilePath = "";
  final updates = MyHomePage.updateInfoJson['description'] as List;
  final version = MyHomePage.updateInfoJson['version'];

  Future downloadNewVersion(String appPath) async {
    final fileName = appPath.split("/").last;
    setState(() {
      isDownloading = true;
    });

    final dio = Dio();

    downloadedFilePath =
        "${(await getDownloadsDirectory())!.path}/$fileName";

    await dio.download(
      "https://raw.githubusercontent.com/alidogangullu/music_player/master/app_versions_check/$appPath",
      downloadedFilePath,
      onReceiveProgress: (received, total) {
        final progress = (received / total) * 100;
        setState(() {
          downloadProgress = double.parse(progress.toStringAsFixed(1));
        });
      },
    );

    //open .exe file
    await Process.start(downloadedFilePath, ["-t", "-l", "1000"])
        .then((value) {});
    setState(() {
      isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (version > ApplicationConfig.currentVersion &&
            !MyHomePage.isUpdateCanceled)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 500,
              height: 400,
              child: ContentDialog(
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text("New Version Found!"),
                      Text("Latest Version $version"),
                      Text(
                          "Current Version: ${ApplicationConfig.currentVersion}"),
                      const SizedBox(
                        height: 7,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("What's new in $version"),
                          const SizedBox(height: 5),
                          ...updates
                              .map((e) => Column(
                                children: [
                                  Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "$e", style: TextStyle(height: 1),
                                            ),
                                          ),
                                        ],
                                      ),
                                  const SizedBox(height: 5)
                                ],
                              ))
                              .toList(),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  Button(
                      child: const Text('Cancel'),
                      onPressed: () {
                        MyHomePage.isUpdateCanceled = true;
                        Navigator.push(
                            context,
                            FluentPageRoute(
                                builder: (context) => const MyHomePage()));
                      }),
                  if (!isDownloading && downloadProgress != 100)
                    FilledButton(
                      onPressed: () {
                        downloadNewVersion(
                            MyHomePage.updateInfoJson["windows_file_name"]);
                      },
                      child: const Text("Update"),
                    ),
                  if (isDownloading && downloadProgress != 100)
                    Column(
                      children: [
                        ProgressRing(
                          value: downloadProgress,
                        ),
                      ],
                    ),
                  if (downloadProgress == 100) const Center(child: Text('Installing...')),
                ],
              ),
            ),
          ),
        if (version <= ApplicationConfig.currentVersion &&
                !MyHomePage.isUpdateCanceled ||
            MyHomePage.isUpdateCanceled)
          Text("Please choose a directory and begin playing music files. " + "v${ApplicationConfig.currentVersion}"),
      ],
    );
  }
}
