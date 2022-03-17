import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/buildGroupCircle.dart';

import '../../models/post.dart';
import '../../shared/constants.dart';
import '../../shared/widgets/myNavigationBar.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  static List<Map> schoolsARs = [
    {C.restriction: "public", C.restrictionType: "country"},
    {C.restriction: "@ltps.info", C.restrictionType: "domain"},
    {C.restriction: "@ndnj.org", C.restrictionType: "domain"},
    {C.restriction: "@@lawrenceville.org", C.restrictionType: "domain"},
  ];
  static List<String> schoolNames = [C.Public, "Lawrence", "Notre Dame", "Lawrenceville"];
  static List<String?> schoolImages = [
    null,
    "https://firebasestorage.googleapis.com/v0/b/hs-connect-db0c0.appspot.com/o/domainPics%2FLTPS.png?alt=media&token=a203f13c-8928-413a-849e-9a7b081f1540",
    "https://bbk12e1-cdn.myschoolcdn.com/ftpimages/334/logo/HomescreenIcon152x152.png",
    "https://upload.wikimedia.org/wikipedia/en/c/cd/Lawrenceville_School_seal.png"
  ];

  List<Post?> topPosts = [null, null, null, null];

  @override
  void initState() {
    getTopPosts();
    super.initState();
  }

  Future _getTopPostsHelper(Map schoolAR, int index, List<Post?> array) async {
    final post = await FirebaseFirestore.instance
        .collection(C.posts)
        .where(C.accessRestriction, isEqualTo: schoolAR)
        .orderBy(C.trendingCreatedAt, descending: true)
        .limit(1)
        .get();
    if (post.size == 0) {
      return;
    }
    array[index] = postFromSnapshot(post.docs[0]);
  }

  void getTopPosts() async {
    List<Post?> newTopPosts = List.filled(schoolsARs.length, null);
    await Future.wait(
        [for (int i = 0; i < schoolsARs.length; i++) _getTopPostsHelper(schoolsARs[i], i, newTopPosts)]);
    if (mounted) {
      setState(() => topPosts = newTopPosts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Schools'),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: schoolsARs.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: colorScheme.background,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                child: Column(
                  children: [
                    Row(
                      children: [
                        buildGroupCircle(
                            groupImage: schoolImages[index],
                            size: 20,
                            context: context,
                            backgroundColor: colorScheme.background),
                        SizedBox(width: 7),
                        Text(schoolNames[index]),
                      ],
                    ),
                    topPosts[index] != null ? Container(child: Text(topPosts[index]!.title)) : Container()
                  ],
                ),
              ),
            );
          }),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
