import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mock_music_player/models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [
    Song(
        songName: "Smells Like Teen Spirit",
        artistName: "Nirvana",
        albumArtImagePath: "assets/images/NirvanaTeenSpirit.jpg",
        audioPath:
            "audio/Nirvana - Smells Like Teen Spirit (Official Music Video).mp3"),
    Song(
        songName: "Something In The Way",
        artistName: "Nirvana",
        albumArtImagePath: "assets/images/NirvanaNevermindAlbum.jpg",
        audioPath:
            "audio/Nirvana - Something In The Way (Live On MTV Unplugged Unedited, 1993).mp3"),
    Song(
        songName: "The Ballad of Mona Lisa",
        artistName: "Panic! At The Disco",
        albumArtImagePath: "assets/images/Vices_&_Virtues.jpg",
        audioPath:
            "audio/Panic! At The Disco_ The Ballad Of Mona Lisa [OFFICIAL VIDEO].mp3")
  ];

  int? _currentSongIndex;

  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;

    if (newIndex != null) {
      play();
    }

    notifyListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  PlaylistProvider({required Function() listenToDuration});

  bool _isPlaying = false;

  void play() async {
    final String path = _playlist[currentSongIndex!].audioPath;
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
    _isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < _playlist.length - 1) {
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        currentSongIndex = 0;
      }
    }
  }

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _playlist.length - 1;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }
}
