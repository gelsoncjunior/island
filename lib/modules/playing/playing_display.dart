import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

class PlayingDisplay extends StatefulWidget {
  const PlayingDisplay({super.key});

  @override
  State<PlayingDisplay> createState() => _PlayingDisplayState();
}

class _PlayingDisplayState extends State<PlayingDisplay> {
  String _currentTrack = '';
  String _currentArtist = '';
  String _currentAlbum = '';
  String _currentPlayerState = 'stopped';
  Timer? _timer;
  Future<String> _command(String command) async {
    final result = await Isolate.run(() {
      return Process.runSync(
        'osascript',
        ['-e', command],
        runInShell: true,
      );
    });
    return result.stdout.toString().trim();
  }

  Future<void> _getSpotifyPlayerState() async {
    final all = await _command(
        'tell application "Spotify" to get player state as string');
    setState(() {
      _currentPlayerState = all;
    });
  }

  Future<void> _getSpotifyPlayerInfo() async {
    await _getSpotifyPlayerState();
    final all = await _command(
        'tell application "Spotify" to get {name, artist, artwork url} of current track');
    final trackName = all.split(',')[0].replaceAll('"', '').trim();
    final trackArtist = all.split(',')[1].replaceAll('"', '').trim();
    final artworkUrl = all.split(',')[2].replaceAll('"', '').trim();
    setState(() {
      _currentTrack = trackName;
      _currentArtist = trackArtist;
      _currentAlbum = artworkUrl;
    });
  }

  void _nextTrack() {
    _command('tell application "Spotify" to next track');
    _getSpotifyPlayerInfo();
  }

  void _previousTrack() {
    _command('tell application "Spotify" to previous track');
    _getSpotifyPlayerInfo();
  }

  void _playPause() {
    _command('tell application "Spotify" to playpause');
    _getSpotifyPlayerInfo();
  }

  @override
  void initState() {
    super.initState();
    _watchSpotify();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void _watchSpotify() {
    _getSpotifyPlayerInfo();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getSpotifyPlayerInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900]!,
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(_currentAlbum),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5), BlendMode.color),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10.0, right: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTrack,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _currentArtist,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousTrack,
                      icon: Icon(Icons.skip_previous, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _playPause,
                      icon: Icon(
                        _currentPlayerState == 'playing'
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextTrack,
                      icon: Icon(Icons.skip_next, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
