import 'dart:convert';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'application.dart';
import 'screens/files.dart';
import 'screens/help.dart';
import 'screens/player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DartVLC.initialize();
  runApp(const MyApp());
  // Add this code below

  doWhenWindowReady(() {
    const initialSize = Size(600, 375);
    appWindow.minSize = initialSize;
    appWindow.maxSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Music Player";
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'Music Player',
        theme: FluentThemeData(
          accentColor: Colors.grey.toAccentColor(),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
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
    if (!MyHomePage.isUpdateCanceled) {
      _checkForUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text("Music Player"),
        leading: const Icon(FluentIcons.music_note),
        actions: WindowTitleBarBox(
          child: Row(
            children: [Expanded(child: MoveWindow()), const WindowButtons()],
          ),
        ),
      ),
      pane: NavigationPane(
        selected: index,
        displayMode: PaneDisplayMode.compact,
        indicator: const StickyNavigationIndicator(
          color: Colors.grey,
        ),
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
            if(EditFiles.files.isEmpty && newIndex == 0) {
              newIndex = 1;
            }
            index = newIndex;
          });
        },
      ),
    );
  }
}