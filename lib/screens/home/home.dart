import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/messagesPage.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/postFeed/mergeFeed.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:validators/validators.dart';
import '../new/newPost/newPost.dart';
import 'homeAppBar.dart';
import 'launchCountdown.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';


class Home extends StatefulWidget {
  final User user;
  final UserData currUserData;

  const Home({Key? key, required this.user, required this.currUserData}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isDomain = false;
  bool searchByTrending = true;
  ScrollController scrollController = ScrollController();

  StreamSubscription? _intentDataStreamSubscriptionImage;
  StreamSubscription? _intentDataStreamSubscriptionURL;

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
    updateAnalytics();
    handleShare();
    super.initState();
  }

  void handleShare() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscriptionImage =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
          if (value.isNotEmpty) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NewPost(initialImage: File(value[0].path))));
          }
        }, onError: (err) {
          print("getIntentDataStream error: $err");
        });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                NewPost(initialImage: File(value[0].path))));
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscriptionURL =
        ReceiveSharingIntent.getTextStream().listen((String value) {
          if (isURL(value)) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NewPost(initialURL: value)));
          }
        }, onError: (err) {
          print("getLinkStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (isURL(value)) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                NewPost(initialURL: value)));
      }
    });
  }

  void updateAnalytics() async {
    await widget.currUserData.userRef.update({"lastHomeView": Timestamp.now()});
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
  void dispose() {
    scrollController.dispose();
    _intentDataStreamSubscriptionImage?.cancel();
    _intentDataStreamSubscriptionURL?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.currUserData.launchDate != null && widget.currUserData.launchDate!.compareTo(Timestamp.now()) > 0) {
      return LaunchCountdown(currUserData: widget.currUserData);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(fullscreenDialog: true, builder: (context) => NewPost()),
            );
          },
          child: Container(
              height: 45,
              width: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: widget.currUserData.domainColor ?? colorScheme.primary,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Icon(Icons.add_rounded, color: colorScheme.brightness == Brightness.light ? colorScheme.surface : colorScheme.onSurface, size: 26))),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate: HomeAppBar(
                  currUserData: widget.currUserData,
                  isDomain: isDomain,
                  toggleFeed: () {
                    if (mounted) {
                      setState(() => isDomain = !isDomain);
                    }
                  },
                  searchByTrending: searchByTrending,
                  toggleSearch: toggleSearch,
                  safeAreaHeight: MediaQuery.of(context).padding.top),
              pinned: true,
              floating: true,
            ),
          ];
        },
        body: isDomain
            ? DomainFeed(
                currUserData: widget.currUserData,
                isDomain: isDomain,
                searchByTrending: searchByTrending,
                key: ValueKey<bool>(searchByTrending),
              )
            : MergeFeed(
                currUserData: widget.currUserData,
                isDomain: isDomain,
                searchByTrending: searchByTrending,
                key: ValueKey<bool>(!searchByTrending)),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 0,
        scrollController: scrollController,
      ),
      extendBody: true,
      resizeToAvoidBottomInset: false,
    );
  }
}
