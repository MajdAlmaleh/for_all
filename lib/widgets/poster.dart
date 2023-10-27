// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/auth_provider.dart';
import 'package:for_all/widgets/my_image_picker.dart';
//import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class Poster extends ConsumerStatefulWidget {
  bool? text;
  bool? image;
  bool? video;
  Poster({
    super.key,
    this.text = true,
    this.image = false,
    this.video = false,
  });

  @override
  ConsumerState<Poster> createState() => _PosterState();
}

class _PosterState extends ConsumerState<Poster> {
  var textController = TextEditingController();
  var _selectedFile;
  var _fileExtinsion;
  // late VideoPlayerController _controller;
  // late Future<void> _initializeVideoPlayerFuture;

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    //  _controller.dispose();
  }

  String mediaType = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: textController,
          onChanged: (value) {
            textController.text = value;
          },
        ),
        if (widget.image == true)
          MyImagePicker(
            isPost: true,
            onPickImage: (pickedImage) async {
              _selectedFile = pickedImage;
            },
          ),
        if (widget.video == true)
          GestureDetector(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp4'],
              );
              _selectedFile = File(result!.files.first.path.toString());
              //      _controller = VideoPlayerController.file(_selectedFile);
              //  _initializeVideoPlayerFuture = _controller.initialize();
              // setState(() {});
            },
            child: const CircleAvatar(
              radius: 90,
              /*    child:_selectedFile==null?null:FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ), */
            ),
          ),
        TextButton(
            onPressed: () async {
              final username = await ref
                  .read(authProvider.notifier)
                  .getUserName(uid: FirebaseAuth.instance.currentUser!.uid);
              final userImage = await ref
                  .read(authProvider.notifier)
                  .getUserImage(uid: FirebaseAuth.instance.currentUser!.uid);
              var createdAt = DateTime.now().millisecondsSinceEpoch;
              if (widget.image == true || widget.video == true) {
                if (widget.image == true) {
                  _fileExtinsion = '.jpg';
                  mediaType = 'image';
                } else {
                  _fileExtinsion = '.mp4';
                  mediaType = 'video';
                }
                final storageRef = FirebaseStorage.instance
                    .ref()
                    .child('posts_data')
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .child('$createdAt$_fileExtinsion');
                await storageRef.putFile(_selectedFile!);
                final dataUrl = await storageRef.getDownloadURL();

                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('post')
                    .add({
                  'createdAt': createdAt,
                  'post_text': textController.text,
                  'post_data': dataUrl,
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                  'username': username,
                  'userImage': userImage,
                  'mediaType': mediaType
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('post')
                    .add({
                  'createdAt': createdAt,
                  'post_text': textController.text,
                  'username': username,
                  'userImage': userImage,
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                  
                });
              }
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
            child: const Text('post'))
      ],
    );
  }
}
