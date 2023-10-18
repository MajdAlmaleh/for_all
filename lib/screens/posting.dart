import 'package:flutter/material.dart';
import 'package:for_all/widgets/poster.dart';

class PostingScreen extends StatefulWidget {
  const PostingScreen({super.key});

  @override
  State<PostingScreen> createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          //todo reset everything
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(

              isScrollable: true,
              tabs:const [
                Text('Text'),
                Text('Photo'),
                Text('Video'),
              ],
              controller: _tabController,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Poster(text: true,),
              Poster(image: true,),
              Poster(video: true,),
            ],
          ),
        ),
      ),
    );
  }
}
