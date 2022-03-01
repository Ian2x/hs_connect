import 'package:hs_connect/shared/inputDecorations.dart';

class PostLikesManager {
  bool likeStatus;
  bool dislikeStatus;
  int likeCount;
  int dislikeCount;
  VoidFunction onLike;
  VoidFunction onUnLike;
  VoidFunction onDislike;
  VoidFunction onUnDislike;

  PostLikesManager(
      {required this.likeStatus,
      required this.dislikeStatus,
      required this.likeCount,
      required this.dislikeCount,
      required this.onLike,
      required this.onUnLike,
      required this.onDislike,
      required this.onUnDislike});
}
