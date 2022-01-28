import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
// Calculate trending by activity within past 1.5 days
const hoursTrending = 36;

class _Gradient extends Color {
  _Gradient(int value) : super(value);

  static Color gRed = HexColor ("FF004D");

  static Color gBlue = HexColor("13A1F0");

  static Color gBlack = Colors.black;
}

class Gradients {
  static LinearGradient blueRed ({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment. bottomRight,
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


const maxDataCollectionRate = 3; // in hours
const maxDataCollectionDays = 2; // in days
const notificationStorageDays = 7; // in days

const double profilePicWidth = 400;
const double profilePicHeight = 400;

const double groupPicWidth = 400;
const double groupPicHeight = 400;

const double commentPicWidth = 400;
const double commentPicHeight = 400;

const double messagePicWidth = 400;
const double messagePicHeight = 400;

const double postPicWidth = 400;
const double postPicHeight = 400;

const numHeightPixels = 781.1;
const numWidthPixels = 392.7;

const initialPostsFetchSize = 5;
const nextPostsFetchSize = 5;

const defaultProfilePic = AssetImage('assets/me.png');

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
  static const lastOverTimeUpdate = 'lastOverTimeUpdate';
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
  static const ianTime = 'ianTime';
  static const fromMe = 'fromMe';
  static const fundamentalName = 'fundamentalName';
}