import 'package:flutter/material.dart';

const maxDataCollectionRate = 3; // in hours (for trending groups)
const maxDataCollectionDays = 2; // in days (for trending groups)

// trendingCreatedAt factors
const trendingCommentBoost = 0.08;
const trendingReplyBoost = 0.1;
const trendingPostLikeBoost = 0.04;
const trendingPollVoteBoost = 0.06;

const numHeightPixels = 781.1;
const numWidthPixels = 392.7;

const initialPostsFetchSize = 20;
const nextPostsFetchSize = 20;

const defaultProfilePic = AssetImage('assets/blankProfile.png');
const defaultGroupPic = AssetImage('assets/defaultgroupimage2.png');

const bottomGradientThickness = 2.0;
const topGradientThickness = 2.0;

const authHintTextColor = Color(0xffdbdada);
const authPrimaryTextColor = Color(0xFFa1a1a1);

const commentReplyDetailSize = 13.0;

const int maxNumNotifications = 50;

class _Gradient extends Color {
  _Gradient(int value) : super(value);

  static Color gRed = Color(0xFFff004d).withOpacity(0.85);
  static Color gRedFull = Color(0xFFff004d);
  static Color gBlue = Color(0xFF13a1f0).withOpacity(0.85);
  static Color gBlueFull = Color(0xFF13a1f0);
}

class Gradients {
  static LinearGradient blueRed ({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment. bottomRight,
    List<double>? stops,
  }){
    return LinearGradient(
      begin: begin,
      end: end,
      stops: stops,
      colors: [ _Gradient.gBlue, _Gradient.gRed],
    );
  }
  static LinearGradient blueRedFull ({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment. bottomRight,
    List<double>? stops,
  }){
    return LinearGradient(
      begin: begin,
      end: end,
      stops: stops,
      colors: [ _Gradient.gBlueFull, _Gradient.gRedFull],
    );
  }
  static LinearGradient blueRedHorizontal ({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }){
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [ _Gradient.gBlue, _Gradient.gRed],
    );
  }
  static LinearGradient solid ({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment. bottomRight,
    required Color color
  }){
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [color, color],
    );
  }
}

class ThemeText {
  static TextStyle inter({Color? color, double? fontSize, double? height,
    TextDecoration? decoration1, FontWeight? fontWeight}) {
    return TextStyle(
        color: color,
        fontSize: fontSize,
        height: height,
        decoration: decoration1,
        fontWeight: fontWeight,
        fontFamily: "Inter"
    );
  }
}

class C {
  static const displayedName = 'displayedName';
  static const displayedNameLC = 'displayedNameLC';
  static const bio = 'bio';
  static const domain = 'domain';
  static const overrideCounty = 'overrideCounty';
  static const overrideState = 'overrideState';
  static const overrideCountry = 'overrideCountry';
  static const modGroupRefs = 'modGroupsRefs';
  static const userMessages = 'userMessages';
  static const profileImageURL = 'profileImageURL';
  static const score = 'score';
  static const groupRef = 'groupRef';
  static const public = 'public';
  static const creatorRef = 'creatorRef';
  static const moderatorRefs = 'moderatorRefs';
  static const name = 'name';
  static const nameLC = 'nameLC';
  static const image = 'image';
  static const description = 'description';
  static const accessRestriction = 'accessRestriction';
  static const createdAt = 'createdAt';
  static const numPosts = 'numPosts';
  static const numMembers = 'numMembers';
  static const restriction = 'restriction';
  static const restrictionType = 'restrictionType';
  static const selfRef = 'selfRef';
  static const commentRef = 'commentRef';
  static const postRef = 'postRef';
  static const text = 'text';
  static const mediaURL = 'mediaURL';
  static const numReplies = 'numReplies';
  static const likes = 'likes';
  static const dislikes = 'dislikes';
  static const title = 'title';
  static const titleLC = 'titleLC';
  static const tag = 'tag';
  static const userData = 'userData';
  static const groups = 'groups';
  static const comments = 'comments';
  static const posts = 'posts';
  static const replies = 'replies';
  static const pollRef = 'pollRef';
  static const messages = 'messages';
  static const senderRef = 'senderRef';
  static const receiverRef = 'receiverRef';
  static const isMedia = 'isMedia';
  static const knownDomains = 'knownDomains';
  static const prompt = 'prompt';
  static const choices = 'choices';
  static const votes = 'votes';
  static const polls = 'polls';
  static const replyRef = 'replyRef';
  static const reportType = 'reportType';
  static const entityRef = 'entityRef';
  static const reporterRef = 'reporterRef';
  static const reports = 'reports';
  static const message = 'message';
  static const post = 'post';
  static const comment = 'comment';
  static const reply = 'reply';
  static const people = 'people';
  static const Relationships = 'Relationships';
  static const Parties = 'Parties';
  static const Memes = 'Memes';
  static const Classes = 'Classes';
  static const Advice = 'Advice';
  static const College = 'College';
  static const Confession = 'Confession';
  static const savedPostsRefs = 'savedPostsRefs';
  static const images = 'images';
  static const profilePics = 'profilePics';
  static const ref = 'ref';
  static const refType = 'refType';
  static const count = 'count';
  static const time = 'time';
  static const postsOverTime = 'postsOverTime';
  static const membersOverTime = 'membersOverTime';
  static const hexColor = 'hexColor';
  static const otherUserRef = 'otherUserRef';
  static const lastMessage = 'lastMessage';
  static const numReports = 'numReports';
  static const numComments = 'numComments';
  static const domainsData = 'domainsData';
  static const fullName = 'fullName';
  static const fullDomainName = 'fullDomainName';
  static const domainColor = 'domainColor';
  static const color = 'color';
  static const country = 'country';
  static const state = 'state';
  static const county = 'county';
  static const Public = 'Public';
  static const lastViewed = 'lastViewed';
  static const commentToPost = 'commentToPost';
  static const replyToReply = 'replyToReply';
  static const replyToComment = 'replyToComment';
  static const parentPostRef = 'parentPostRef';
  static const myNotificationType = 'myNotificationType';
  static const sourceRef = 'sourceRef';
  static const myNotifications = 'myNotifications';
  static const private = 'private';
  static const sourceUserRef = 'sourceUserRef';
  static const sourceUserDisplayedName = 'sourceUserDisplayedName';
  static const sourceUserFullDomainName = 'sourceUserFullDomainName';
  static const profileImage = 'profileImage';
  static const replyVotes = 'replyVotes';
  static const commentVotes = 'commentVotes';
  static const postVotes = 'postVotes';
  static const extraData = 'extraData';
  static const fromMe = 'fromMe';
  static const fundamentalName = 'fundamentalName';
  static const trendingCreatedAt = 'trendingCreatedAt';
  static const loginName = 'loginName';
  static const featuredPost = 'featuredPost';
  static const feedback = 'feedback';
  static const feedbackText = 'feedbackText';
  static const isFeatured = 'isFeatured';
  static const notificationsLastViewed = 'notificationsLastViewed';
  static const recoveryCode = 'recoveryCode';
  static const type = 'type';
  static const postId = 'postId';
  static const launchDate = 'launchDate';
  static const mature = 'mature';
  static const user = 'user';
  static const blockedPostRefs = 'blockedPostRefs';
  static const blockedUserRefs = 'blockedUserRefs';
  static const link = 'link';
  static const tokens = 'tokens';
  static const contentNotification = 'contentNotification';
  static const dmNotification = 'dmNotification';
  static const otherUserId = 'otherUserId';
  static const notifiedUserRef = 'notifiedUserRef';
}