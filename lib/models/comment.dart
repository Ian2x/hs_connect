class Comment {
  final String commentId;
  final String postId;
  final String userId;
  String text;
  String? image;
  final String createdAt;
  List<String> likes;
  List<String> dislikes;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.text,
    required this.image,
    required this.createdAt,
    required this.likes,
    required this.dislikes,
  });
}