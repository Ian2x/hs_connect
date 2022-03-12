import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/messagesPage.dart';
import 'package:hs_connect/screens/authenticate/waitVerification.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/postFeed/publicFeed.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import '../new/newPost/postForm.dart';
import 'homeAppBar.dart';
import 'launchCountdown.dart';

class Home extends StatefulWidget {
  final User user;
  final UserData currUserData;

  const Home({Key? key, required this.user, required this.currUserData}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isDomain = true;
  bool searchByTrending = true;

  void toggleSearch(bool newSearchByTrending) {
    if (mounted) {
      MyStorageManager.saveData('searchByTrending', newSearchByTrending);
      setState(() => searchByTrending = newSearchByTrending);
    }
  }

  @override
  void initState() {
    handleNewUser();
    setupInteractedMessage();
    subscribeToDomainTopicAndAllowAlerts();
    getSearchByTrending();
    saveTokenToDatabase();
    super.initState();
  }

  void handleNewUser() async {
    dynamic showSignUp = await MyStorageManager.readData('showSignUp');
    if (showSignUp == true) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final textTheme = Theme.of(context).textTheme;
            final colorScheme = Theme.of(context).colorScheme;
            String domain = widget.currUserData.fullDomainName ?? widget.currUserData.domain;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 30),
              backgroundColor: colorScheme.surface,
              titlePadding: EdgeInsets.fromLTRB(20, 30, 20, 0),
              title: Text(
                "Hey! You're user " +
                    widget.currUserData.fundamentalName.replaceAll(
                        RegExp(widget.currUserData.domain.replaceAll(RegExp(r'(\.com|\.org|\.info|\.edu|\.net)'), '')),
                        "") +
                    " from " +
                    domain +
                    ", so we gave you the name:",
                textAlign: TextAlign.center,
                style: textTheme.headline6?.copyWith(fontSize: 18),
              ),
              content: Container(
                width: 100,
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                alignment: Alignment.topCenter,
                child: Text(
                  widget.currUserData.fundamentalName,
                  style: textTheme.headline4?.copyWith(fontSize: 24, color: widget.currUserData.domainColor),
                ),
              ),
            );
          },
        );
      });
      MyStorageManager.deleteData('showSignUp');
    }
  }

  void saveTokenToDatabaseHelper(String token) async {
    widget.currUserData.userRef.update({
      C.tokens: FieldValue.arrayUnion([token])
    });
  }

  void saveTokenToDatabase() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      saveTokenToDatabaseHelper(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabaseHelper);
  }

  void getSearchByTrending() async {
    final data = await MyStorageManager.readData('searchByTrending');
    if (mounted) {
      if (data == true) {
        setState(() => searchByTrending = true);
      } else {
        setState(() => searchByTrending = false);
      }
    }
  }

  void subscribeToDomainTopicAndAllowAlerts() async {
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance.subscribeToTopic(widget.currUserData.domain.substring(1));
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
    }
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    // If the message also contains a data property with a "type" of "chat", navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future openMessagePost(RemoteMessage message) async {
    Post post =
        postFromSnapshot(await FirebaseFirestore.instance.collection(C.posts).doc(message.data[C.postId]).get());
    Group? group = await groupFromSnapshot(await post.groupRef.get());
    if (group != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostPage(
                  post: post,
                  group: group,
                  postLikesManager: PostLikesManager(
                      likeStatus: post.likes.contains(widget.currUserData.userRef),
                      dislikeStatus: post.dislikes.contains(widget.currUserData.userRef),
                      likeCount: post.likes.length,
                      dislikeCount: post.dislikes.length,
                      onLike: () {},
                      onUnLike: () {},
                      onDislike: () {},
                      onUnDislike: () {}))));
    }
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.data[C.type] == C.featuredPost) {
      // not really gonna be using this model much anymore
      openMessagePost(message);
    } else if (message.data[C.type] == C.contentNotification) {
      if (message.data[C.postId] == 'fake') {
        // figure out something later
      } else {
        openMessagePost(message);
      }
    } else if (message.data[C.type] == C.dmNotification) {
      final otherUserRef = FirebaseFirestore.instance.collection(C.userData).doc(message.data[C.otherUserId]);
      final otherUser = await userDataFromSnapshot(await otherUserRef.get(), otherUserRef);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessagesPage(
                    currUserRef: widget.currUserData.userRef,
                    otherUserRef: otherUser.userRef,
                    onUpdateLastMessage: () {},
                    onUpdateLastViewed: () {},
                    otherUserFundName: otherUser.fundamentalName,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.currUserData.launchDate != null && widget.currUserData.launchDate!.compareTo(Timestamp.now()) > 0) {
      return LaunchCountdown(currUserData: widget.currUserData);
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      floatingActionButton: IconButton(
        icon: Container(
            alignment: Alignment.center,
            decoration: ShapeDecoration(shape: CircleBorder(), color: colorScheme.onSurface),
            child: Icon(Icons.add_rounded, color: colorScheme.surface, size: 35)),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        onPressed: () {
          final topPadding = MediaQuery.of(context).padding.top;
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return PostForm(currUserData: widget.currUserData, topPadding: topPadding);
              },
              isScrollControlled: true);
        },
      ),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate: HomeAppBar(
                  currUserData: widget.currUserData,
                  isDomain: isDomain,
                  searchByTrending: searchByTrending,
                  toggleSearch: toggleSearch,
                  safeAreaHeight: MediaQuery.of(context).padding.top),
              pinned: true,
              floating: true,
            ),
          ];
        },
        body: DomainFeed(
          currUserData: widget.currUserData,
          isDomain: isDomain,
          searchByTrending: searchByTrending,
          key: ValueKey<bool>(searchByTrending),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
