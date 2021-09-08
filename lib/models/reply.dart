class Reply {
  final String replyId;
  final String commentId;
  final String userId;
  String text;
  String? image;
  final String createdAt;
  List<String> likes;
  List<String> dislikes;

  Reply({
    required this.replyId,
    required this.commentId,
    required this.userId,
    required this.text,
    required this.image,
    required this.createdAt,
    required this.likes,
    required this.dislikes,
  });
}