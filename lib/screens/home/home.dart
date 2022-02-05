import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/postFeed/publicFeed.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

import 'homeAppBar.dart';

class Home extends StatefulWidget {
  final UserData userData;
  const Home({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isDomain = true;
  late TabController tabController;
  ScrollController scrollController = ScrollController();
  var top = 0.0;

  @override
  void initState() {
    setupInteractedMessage();
    subscribeToDomain();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (mounted) {
        setState(() {
          isDomain = tabController.index == 0;
        });
      }
      scrollController.jumpTo(0);
    });
    super.initState();
  }

  void subscribeToDomain() async {
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus==AuthorizationStatus.authorized) {
      print('subscribing to topic: ' + widget.userData.domain.substring(1));
      await FirebaseMessaging.instance.subscribeToTopic(widget.userData.domain.substring(1));
    }
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat", navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.data[C.type] == C.featuredPost) {
      Post post = postFromSnapshot(await FirebaseFirestore.instance.collection(C.posts).doc(message.data[C.postId]).get());
      final data = await waitConcurrently(groupFromSnapshot(await post.groupRef.get()), userDataFromSnapshot(await post.creatorRef.get(), post.creatorRef));
      Group? group = data.item1;
      UserData creatorData = data.item2;
      if (group!=null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    pixelProvider(context,
                        child: PostPage(post: post, group: group, creatorData: creatorData, postLikesManager: PostLikesManager(
                            likeStatus: post.likes.contains(widget.userData.userRef),
                            dislikeStatus: post.dislikes.contains(widget.userData.userRef),
                            likeCount: post.likes.length,
                            dislikeCount: post.dislikes.length,
                            onLike: () {}, onUnLike: () {}, onDislike: () {}, onUnDislike: () {}))
                    )));
      }
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Scaffold(backgroundColor: colorScheme.background, body: Loading());
    }
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: <Widget>[
          NestedScrollView(
            floatHeaderSlivers: true,
            controller: scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverPersistentHeader(
                  delegate: HomeAppBar(tabController: tabController, userData: userData, isDomain: isDomain),
                  pinned: true,
                  floating: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                DomainFeed(currUser: userData, isDomain: isDomain),
                PublicFeed(currUser: userData, isDomain: isDomain),
              ],
              controller: tabController,
              physics: AlwaysScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(currentIndex: 0, currUserData: widget.userData,),
    );
  }
}

