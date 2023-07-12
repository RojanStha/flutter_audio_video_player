// import 'dart:math';

// import 'package:audio_session/audio_session.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart' as ja;
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// const List<String> _videoIds = [
//   'tcodrIK2P_I',
//   'H5v3kku4y6Q',
//   'nPt8bK2gbaU',
//   'K18cpp_-gP8',
//   'iLnmTe5Q2Qw',
//   '_WoCV4c6XOE',
//   'KmzdUe0RSJo',
//   '6jZDSSZZxjQ',
//   'p2lYr3vM_1w',
//   '7QUtEmBT_-w',
//   '34_PXCzGw1M'
// ];

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late YoutubePlayerController _controller;
//   final _player = ja.AudioPlayer(
//     // Handle audio_session events ourselves for the purpose of this demo.
//     handleInterruptions: false,
//     androidApplyAudioAttributes: false,
//     handleAudioSessionActivation: false,
//   );
//   setData() {
//     _controller = YoutubePlayerController(
//       params: const YoutubePlayerParams(
//         showControls: true,
//         mute: false,
//         showFullscreenButton: true,
//         loop: false,
//       ),
//     );

//     _controller.loadPlaylist(
//       list: _videoIds,
//       listType: ListType.playlist,
//       startSeconds: 136,
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     setData();
//     AudioSession.instance.then((audioSession) async {
//       // This line configures the app's audio session, indicating to the OS the
//       // type of audio we intend to play. Using the "speech" recipe rather than
//       // "music" since we are playing a podcast.
//       await audioSession.configure(AudioSessionConfiguration.speech());
//       // Listen to audio interruptions and pause or duck as appropriate.
//       _handleInterruptions(audioSession);
//       // Use another plugin to load audio to play.
//       await _player.setUrl(
//           "https://cdn.pixabay.com/audio/2021/09/08/audio_30fd70d538.mp3");
//     });
//   }

//   void _handleInterruptions(AudioSession audioSession) {
//     // just_audio can handle interruptions for us, but we have disabled that in
//     // order to demonstrate manual configuration.
//     bool playInterrupted = false;
//     audioSession.becomingNoisyEventStream.listen((_) {
//       print('PAUSE');
//       _player.pause();
//     });
//     _player.playingStream.listen((playing) {
//       playInterrupted = false;
//       if (playing) {
//         audioSession.setActive(true);
//       }
//     });
//     audioSession.interruptionEventStream.listen((event) {
//       print('interruption begin: ${event.begin}');
//       print('interruption type: ${event.type}');
//       if (event.begin) {
//         switch (event.type) {
//           case AudioInterruptionType.duck:
//             if (audioSession.androidAudioAttributes!.usage ==
//                 AndroidAudioUsage.game) {
//               _player.setVolume(_player.volume / 2);
//             }
//             playInterrupted = false;
//             break;
//           case AudioInterruptionType.pause:
//           case AudioInterruptionType.unknown:
//             if (_player.playing) {
//               _player.pause();
//               playInterrupted = true;
//             }
//             break;
//         }
//       } else {
//         switch (event.type) {
//           case AudioInterruptionType.duck:
//             _player.setVolume(min(1.0, _player.volume * 2));
//             playInterrupted = false;
//             break;
//           case AudioInterruptionType.pause:
//             if (playInterrupted) _player.play();
//             playInterrupted = false;
//             break;
//           case AudioInterruptionType.unknown:
//             playInterrupted = false;
//             break;
//         }
//       }
//     });
//     audioSession.devicesChangedEventStream.listen((event) {
//       print('Devices added: ${event.devicesAdded}');
//       print('Devices removed: ${event.devicesRemoved}');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('audio_session example'),
//         ),
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: YoutubePlayer(
//                   controller: _controller,
//                   aspectRatio: 1,
//                 ),
//               ),
//               Expanded(
//                 child: Center(
//                   child: StreamBuilder<ja.PlayerState>(
//                     stream: _player.playerStateStream,
//                     builder: (context, snapshot) {
//                       final playerState = snapshot.data;
//                       if (playerState?.processingState !=
//                           ja.ProcessingState.ready) {
//                         return Container(
//                           margin: EdgeInsets.all(8.0),
//                           width: 64.0,
//                           height: 64.0,
//                           child: CircularProgressIndicator(),
//                         );
//                       } else
//                       if (playerState?.playing == true) {
//                         return IconButton(
//                           icon: Icon(Icons.pause),
//                           iconSize: 64.0,
//                           onPressed: _player.pause,
//                         );
//                       } else {
//                         return IconButton(
//                           icon: Icon(Icons.play_arrow),
//                           iconSize: 64.0,
//                           onPressed: _player.play,
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//               // Expanded(
//               //   child: FutureBuilder<AudioSession>(
//               //     future: AudioSession.instance,
//               //     builder: (context, snapshot) {
//               //       final session = snapshot.data;
//               //       if (session == null) return SizedBox();
//               //       return StreamBuilder<Set<AudioDevice>>(
//               //         stream: session.devicesStream,
//               //         builder: (context, snapshot) {
//               //           final devices = snapshot.data ?? {};
//               //           return Column(
//               //             crossAxisAlignment: CrossAxisAlignment.center,
//               //             children: [
//               //               Text("Input devices",
//               //                   style: Theme.of(context).textTheme.titleLarge),
//               //               for (var device
//               //                   in devices.where((device) => device.isInput))
//               //                 Text(
//               //                     '${device.name} (${describeEnum(device.type)})'),
//               //               SizedBox(height: 16),
//               //               Text("Output devices",
//               //                   style: Theme.of(context).textTheme.titleLarge),
//               //               for (var device
//               //                   in devices.where((device) => device.isOutput))
//               //                 Text(
//               //                     '${device.name} (${describeEnum(device.type)})'),
//               //             ],
//               //           );
//               //         },
//               //       );
//               //     },
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//Second Implementation
// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late VlcPlayerController _videoPlayerController;

//   Future<void> initializePlayer() async {}

//   @override
//   void initState() {
//     super.initState();

//     _videoPlayerController = VlcPlayerController.network(
//       'https://youtu.be/Z2mmfepKVKQ',
//       hwAcc: HwAcc.full,
//       autoPlay: true,
//       options: VlcPlayerOptions(),
//     );

//   }

//   @override
//   void dispose() async {
//     super.dispose();
//     await _videoPlayerController.stopRendererScanning();
//     // await _videoViewController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(),
//         body: Center(
//           child: VlcPlayer(
//             controller: _videoPlayerController,
//             aspectRatio: 16 / 9,
//             placeholder: Center(child: CircularProgressIndicator()),
//           ),
//         ));
//   }
// }
//Second Implementation

//Third time

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube and Audio Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late YoutubePlayerController _youtubeController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'tcodrIK2P_I',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void playAudio() async {
    await _audioPlayer
        .play('https://cdn.pixabay.com/audio/2021/09/08/audio_30fd70d538.mp3');
    _youtubeController.play();
  }

  void pauseAudio() async {
    await _audioPlayer.pause();
  }

  void stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube and Audio Player'),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _youtubeController,
            showVideoProgressIndicator: true,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: playAudio,
              ),
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: pauseAudio,
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: stopAudio,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
