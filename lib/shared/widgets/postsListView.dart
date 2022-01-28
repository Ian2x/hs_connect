import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/postView/postCard.dart';

import 'loading.dart';

ListView postsListView({required List<Post> posts, required DocumentReference currUserRef, required ScrollController scrollController}) {
  return ListView.builder(
      itemCount: posts.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      controller: scrollController,
      physics: PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemBuilder: (BuildContext context, int index) {
        if (index==posts.length - 1) {
          return Column(
            children: <Widget>[
              Center(
                  child: PostCard(
                    post: posts[index],
                    currUserRef: currUserRef,
                  )),
              SizedBox(height: 30),
              Loading(size: 42),
              SizedBox(height: 30),
            ]
          );
        }
        return Center(
            child: PostCard(
          post: posts[index],
          currUserRef: currUserRef,
        ));
      });
}
