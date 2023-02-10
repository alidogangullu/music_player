import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:music_player/player.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'files.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(600, 400));
    WindowManager.instance.setMaximumSize(const Size(600, 400));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Simple Music Player',
      theme: ThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(title: Text("Simple Music Player")),
      pane: NavigationPane(
        selected: index,
        displayMode: PaneDisplayMode.compact,
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

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Help"),
    );
  }
}
