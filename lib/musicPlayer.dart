import 'dart:io';
import 'dart:typed_data';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flac_metadata/flacstream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mp3_info/mp3_info.dart';
import 'package:music_player/screens/files.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter/src/widgets/image.dart' // ignore: implementation_imports
    as img;
import 'package:riverpod/riverpod.dart';

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerStateNotifier, MusicPlayerState>((ref) {
  return MusicPlayerStateNotifier();
});

class MusicPlayerState {
  Player player;
  MP3Info? mp3;
  String playingFilePath = "";
  Duration duration = const Duration();
  Duration position = const Duration();
  Duration seek = const Duration();
  Uint8List? albumArt;
  bool isArtNull = true;
  Color themeColor = Colors.grey;
  String songName = "";
  String artistName = "";
  String albumName = "";
  int? bitrate, sampleRate, bitsPerSample;
  bool isPlaying = false;
  bool isSeeking = false;
  bool pathAdded = false;

  MusicPlayerState({
    required this.player,
    this.mp3,
    required this.playingFilePath,
    this.duration = const Duration(),
    this.position = const Duration(),
    this.seek = const Duration(),
    this.albumArt,
    this.isArtNull = true,
    this.themeColor = Colors.grey,
    this.songName = "",
    this.artistName = "",
    this.albumName = "",
    this.bitrate,
    this.sampleRate,
    this.bitsPerSample,
    this.isPlaying = false,
    this.isSeeking = false,
    this.pathAdded = false,
  });
}

class MusicPlayerStateNotifier extends StateNotifier<MusicPlayerState> {
  MusicPlayerStateNotifier()
      : super(MusicPlayerState(
            player: Player(id: 69420, commandlineArguments: ['--no-video']), playingFilePath: EditFiles.files.first)) {
    initialize();
  }

  Future<void> getImageAndGeneratePalette(Uint8List? albumArt) async {
    if (albumArt != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(img.MemoryImage(albumArt));
      state = state.copyWith(themeColor: paletteGenerator.dominantColor!.color);
    } else {
      state = state.copyWith(themeColor: Colors.grey);
    }
  }

  Future<void> play() async {
    if (state.pathAdded) {
      state.player.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  Future<void> pause() async {
    state.player.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> stop() async {
    state.player.stop();
    state = state.copyWith(isPlaying: false);
  }

  void next() {
    int index = EditFiles.files.indexOf(state.playingFilePath);
    if (index + 1 <= EditFiles.files.length - 1) {
      state = state.copyWith(playingFilePath: EditFiles.files[index + 1]);
      initFile();
    } else {
      state = state.copyWith(playingFilePath: EditFiles.files.first);
      initFile();
    }
    play();
  }

  void previous() {
    int index = EditFiles.files.indexOf(state.playingFilePath);
    if (index - 1 >= 0) {
      state = state.copyWith(playingFilePath: EditFiles.files[index - 1]);
      initFile();
    } else {
      state = state.copyWith(playingFilePath: EditFiles.files.last);
      initFile();
    }
    play();
  }

  Future<void> getMetadata() async {
    if (state.playingFilePath.split(".").last == "mp3") {
      state.mp3 = MP3Processor.fromFile(File(state.playingFilePath));
      state.sampleRate = int.parse(
          state.mp3!.sampleRate.toString().split(".").last.split("_").last);
      state.bitrate = state.mp3!.bitrate;
    } else if (state.playingFilePath.split(".").last == "flac") {
      var metadata =
          await FlacInfo(File(state.playingFilePath)).readMetadatas();
      state.sampleRate = int.parse(
          metadata.toString().split("sampleRate: ")[1].split(",").first);
      state.bitsPerSample = int.parse(
          metadata.toString().split("bitsPerSample: ")[1].split(",").first);
      state.bitrate = ((state.bitsPerSample! *
                  state.sampleRate! *
                  int.parse(metadata
                      .toString()
                      .split("channels: ")[1]
                      .split(",")
                      .first)) /
              1000)
          .round();
    }

    await MetadataGod.readMetadata(file: state.playingFilePath).then((value) {
      state.albumArt = null;
      state.isArtNull = true;

      if (value.picture != null) {
        state.albumArt = value.picture!.data;
        state.isArtNull = false;
      } else {
        state.isArtNull = true;
      }

      getImageAndGeneratePalette(state.albumArt);

      state.albumName = value.album ?? "";
      state.artistName = value.artist ?? "";
      state.songName = value.title ?? "";
    });
  }

  void initFile() {
    state.player.open(
      Playlist(
        medias: [
          Media.file(File(state.playingFilePath)),
        ],
      ),
      autoStart: false,
    );
    getMetadata();
  }

  void initAudioPlayer() {
    state.player.positionStream.listen((value) {
      state =
          state.copyWith(position: value.position!, duration: value.duration!);
    });
  }

  void initialize() {
    if (EditFiles.files.isNotEmpty) {
      state = state.copyWith(pathAdded: true);
      initFile();
      initAudioPlayer();
    }
    MetadataGod.initialize();
  }

  void seekTo(double value) {
    state = state.copyWith(seek: Duration(milliseconds: value.round()));
  }

  void startSeeking() {
    state = state.copyWith(isSeeking: true);
  }

  void endSeeking(double value) {
    state = state.copyWith(isSeeking: false);
    state.player.seek(Duration(milliseconds: value.round()));
  }
}

extension MusicPlayerStateExtension on MusicPlayerState {
  String get durationText => duration.toString().split('.').first;
  String get positionText => position.toString().split('.').first;
  String get seekText => seek.toString().split('.').first;

  MusicPlayerState copyWith({
    Player? player,
    MP3Info? mp3,
    String? playingFilePath,
    Duration? duration,
    Duration? position,
    Duration? seek,
    Uint8List? albumArt,
    bool? isArtNull,
    Color? themeColor,
    String? songName,
    String? artistName,
    String? albumName,
    int? bitrate,
    int? sampleRate,
    int? bitsPerSample,
    bool? isPlaying,
    bool? isSeeking,
    bool? pathAdded,
  }) {
    return MusicPlayerState(
      player: player ?? this.player,
      mp3: mp3 ?? this.mp3,
      playingFilePath: playingFilePath ?? this.playingFilePath,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      seek: seek ?? this.seek,
      albumArt: albumArt ?? this.albumArt,
      isArtNull: isArtNull ?? this.isArtNull,
      themeColor: themeColor ?? this.themeColor,
      songName: songName ?? this.songName,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      bitsPerSample: bitsPerSample ?? this.bitsPerSample,
      isPlaying: isPlaying ?? this.isPlaying,
      isSeeking: isSeeking ?? this.isSeeking,
      pathAdded: pathAdded ?? this.pathAdded,
    );
  }
}
