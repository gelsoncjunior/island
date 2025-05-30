import 'dart:async';

import 'package:flutter/material.dart';

import '../cmd/cmd.dart';

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

  Future<void> _getSpotifyPlayerState() async {
    final all = await command(
        'tell application "Spotify" to get player state as string');
    if (mounted) {
      setState(() {
        _currentPlayerState = all;
      });
    }
  }

  Future<void> _getSpotifyPlayerInfo() async {
    try {
      await _getSpotifyPlayerState();
      final all = await command(
          'tell application "Spotify" to get {name, artist, artwork url} of current track');
      final trackName = all.split(',')[0].replaceAll('"', '').trim();
      final trackArtist = all.split(',')[1].replaceAll('"', '').trim();
      final artworkUrl = all.split(',')[2].replaceAll('"', '').trim();
      if (mounted) {
        setState(() {
          _currentTrack = trackName;
          _currentArtist = trackArtist;
          _currentAlbum = artworkUrl;
        });
      }
    } catch (e) {
      debugPrint('Error getting Spotify player info: $e');
    }
  }

  void _nextTrack() {
    command('tell application "Spotify" to next track');
    _getSpotifyPlayerInfo();
  }

  void _previousTrack() {
    command('tell application "Spotify" to previous track');
    _getSpotifyPlayerInfo();
  }

  void _playPause() {
    command('tell application "Spotify" to playpause');
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
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            onError: (_, __) {
              setState(() {
                _currentAlbum =
                    'https://marketplace.canva.com/EAFvLSrAX9U/1/0/1600w/canva-music-desktop-wallpaper-qgZBY-Ll2Vc.jpg';
              });
            },
            image: NetworkImage(_currentAlbum, scale: 1),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5), BlendMode.color),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.topRight,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
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
