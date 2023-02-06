import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart';

class MusicPlayer extends StatefulWidget {
  MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();
  String localFile = "C:/Users/alido/Downloads/Ezhel - Kuğulu Park.flac";

  @override
  void initState() {
    player.setSource(DeviceFileSource(localFile));
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
            child: Image.network(
                "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/rap-mixtape-cover-art-design-template-ca79baae8c3ee8f1112ae28f7bfaa1e0_screen.jpg?ts=1635176249"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Song Name"),
              Text("Album Name"),
              Text("Some Info"),
              Padding(
                padding: const EdgeInsets.only(top: 20),
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
                      icon: Icon(FluentIcons.pause),
                      onPressed: () async {
                        await player.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      },
                    )
                  : IconButton(
                      icon: Icon(FluentIcons.play_solid),
                      onPressed: () async {
                        await player.resume();
                        setState(() {
                          isPlaying = true;
                        });
                      },
                    ),
            ],
          ),
        )
      ],
    );
  }
}
