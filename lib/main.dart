import 'dart:convert';
import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:http/http.dart' as http;
import 'application.dart';
import 'screens/files.dart';
import 'screens/help.dart';
import 'screens/player.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(600, 400));
    WindowManager.instance.setMaximumSize(const Size(600, 400));
    WindowManager.instance.center();
  }
  DartVLC.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Music Player',
      theme: ThemeData(
        accentColor: Colors.grey.toAccentColor(),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static bool isUpdateCanceled = false;
  static var updateInfoJson;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 1;

  Future<Map<String, dynamic>> loadJsonFromGithub() async {
    final response = await http.read(Uri.parse(
        "https://raw.githubusercontent.com/alidogangullu/music_player/master/app_versions_check/version.json"));
    return jsonDecode(response);
  }

  Future<void> _checkForUpdates() async {
    final jsonVal = await loadJsonFromGithub();
    MyHomePage.updateInfoJson = jsonVal;
    final githubVersion = jsonVal['version'];
    if (githubVersion > ApplicationConfig.currentVersion) {
      setState(() {
      index = 2;
    });
    }
  }

  @override
  void initState() {
    super.initState();
    if(!MyHomePage.isUpdateCanceled) {
      _checkForUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(title: Text("Music Player"),),
      pane: NavigationPane(
        selected: index,
        displayMode: PaneDisplayMode.compact,
        indicator: const StickyNavigationIndicator(color: Colors.grey,),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.play),
            title: const Text("Player"),
            body: const MusicPlayer(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.edit),
            title: const Text("Edit"),
            body: const EditFiles(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.help),
            title: const Text("Help"),
            body: const Help(),
          )
        ],
        onChanged: (newIndex) {
          setState(() {
            index = newIndex;
          });
        },
      ),
    );
  }
}