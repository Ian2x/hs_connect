import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/post_view/post_card2.dart';

ListView PostsListView({required List<Post> posts, required DocumentReference currUserRef}) {
  return ListView.builder(
      itemCount: posts.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
      // when scroll up/down, fires once
        return Center(
            child: PostCard2(
          postRef: posts[index].postRef,
          userRef: posts[index].userRef,
          groupRef: posts[index].groupRef,
          title: posts[index].title,
          LCtitle: posts[index].LCtitle,
          text: posts[index].text,
          media: posts[index].media,
          createdAt: posts[index].createdAt,
          likes: posts[index].likes,
          dislikes: posts[index].dislikes,
          currUserRef: currUserRef,
          numComments: posts[index].numComments,
          reportedStatus: posts[index].reports,
          tags: posts[index].tags,
        )
        );
      });
}
