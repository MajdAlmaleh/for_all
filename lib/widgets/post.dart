import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
class Post extends StatefulWidget {
  final String postText;
  String? postMedia;
  final String username;
  final String userImage;
  final String? mediaType;
  Post({
    super.key,
    required this.postText,
    required this.postMedia,
    required this.username,
    required this.userImage,
    required this.mediaType,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  var _controller;

  @override
  void initState() {
    super.initState();
    if (widget.postMedia != null && widget.mediaType == 'video') {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.postMedia!))
            ..initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              if (mounted) {
                setState(() {});
              }
            });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.postMedia != null &&
        widget.mediaType == 'video' &&
        _controller == null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.postMedia!))
            ..initialize().then((_) {});
    }
    return Card(
      child: Column(
        children: [
          const SizedBox(
            width: double.infinity,
          ),
          ListTile(
            leading: CircleAvatar(
                radius: 20, backgroundImage: NetworkImage(widget.userImage)),
            title: Text(widget.username),
          ),
          Text(widget.postText), //  Image.network(widget.postMedia!),

          if (widget.postMedia != null && widget.mediaType == 'image')
            Image.network(widget.postMedia!),

          if (widget.postMedia != null && widget.mediaType == 'image')
            CachedNetworkImage(
              key: UniqueKey(),
              imageUrl: widget.postMedia!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                          Colors.red, BlendMode.colorBurn)),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),

          if (widget.postMedia != null && widget.mediaType == 'video')
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
          if (widget.postMedia != null && widget.mediaType == 'video')
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
        ],
      ),
    );
  }
}
