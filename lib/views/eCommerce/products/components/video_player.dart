import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  String videoUrl;
  VideoPlayer({
    super.key,
    required this.videoUrl,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoCardViewState();
}

class _VideoCardViewState extends ConsumerState<VideoPlayer> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool isCompleted = false;

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     // App is in the background, pause the audio
  //     ref.read(courseController).videoPlayerController?.pause();
  //   }
  //   if (state == AppLifecycleState.resumed) {
  //     // App is back to the foreground, resume the audio if it was playing before
  //     ref.read(courseController).videoPlayerController?.play();
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      aspectRatio: 16.0 / 9.0,
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      showControls: true,
      showOptions: false,
      allowPlaybackSpeedChanging: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Chewie(controller: _chewieController))
        : Container();
  }
}
