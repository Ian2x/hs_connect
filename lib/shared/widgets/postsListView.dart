import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/postView/postCard.dart';

ListView postsListView({required List<Post> posts, required ScrollController controller, required DocumentReference currUserRef}) {
  return ListView.builder(
      itemCount: posts.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      controller: controller,
      itemBuilder: (BuildContext context, int index) {
        // when scroll up/down, fires once
        return Center(
            child: PostCard(
          post: posts[index],
          currUserRef: currUserRef, hp: 1, wp: 1,
        ));
      });
}
