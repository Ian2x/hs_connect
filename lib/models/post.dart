class Post {
  final String postId;
  final String userId;
  final String groupId;
  String title;
  String text;
  String? image;
  final String createdAt;
  List<String> likes;
  List<String> dislikes;

  Post({
    required this.postId,
    required this.userId,
    required this.groupId,
    required this.title,
    required this.text,
    required this.image,
    required this.createdAt,
    required this.likes,
    required this.dislikes,
  });
}
