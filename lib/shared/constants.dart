import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

// Calculate trending by activity within past 1.5 days
const hoursTrending = 36;

const maxDataCollectionRate = 3; // in hours
const maxDataCollectionDays = 2; // in days
const notificationStorageDays = 7; // in days

const double profilePicWidth = 400;
const double profilePicHeight = 400;

const double groupPicWidth = 400;
const double groupPicHeight = 400;

//TODO: May have to do sizing based on Media.context(of)


class ThemeLayout {
  static double borderRadius = 15.0;
}

class ThemeText {

  static TextStyle postViewText({Color? color, double fontSize=18, double height=1.0}) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: "Roboto",
      height: height,
      fontWeight: FontWeight.normal,
      color: color != null ? color: ThemeColor.mediumGrey,
    );
  }

  static TextStyle postViewTitle({Color? color, double fontSize=18, double height=1.0}) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: "Roboto",
      height: height,
      fontWeight: FontWeight.w500,
      color: color != null ? color: ThemeColor.darkGrey,
    );
  }

  static TextStyle titleRegular({Color? color, double fontSize=18}) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: "Inter",
      color: color != null ? color: ThemeColor.darkGrey,
    );
  }

  static TextStyle groupBold ({Color? color, double fontSize=13.0}){
    return TextStyle(
      fontSize: fontSize,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: color != null ? color : ThemeColor.darkGrey,
      );
  }

  static TextStyle regularSmall ({Color? color, double fontSize=13.0, double height=1.0}){
    return TextStyle(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.normal,
      fontFamily: "Inter",
      color: color != null ? color: ThemeColor.darkGrey,
    );
  }

  static TextStyle inter({Color? color, double? fontSize, double? height, FontWeight? fontWeight}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      fontFamily: "Inter"
    );
  }

  static TextStyle roboto({Color? color, double? fontSize, double? height, FontWeight? fontWeight}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      fontFamily: "Roboto"
    );
  }

  static double regular = 16.0;
}

class ThemeColor extends Color {
  ThemeColor(int value) : super(value);

  static Color backgroundGrey = HexColor ("F4F4F4");

  static Color hintTextGrey = HexColor("C8CED2");

  static Color secondaryBlue = HexColor("13A1F0");


  static Color lightGrey = HexColor("F4F4F4");
  static Color lightMediumGrey = HexColor("C9C9C9");
  static Color mediumGrey = HexColor("b2b2b2");
  static Color darkGrey = HexColor("373a3d");

  static Color white = HexColor("FFFFFF");
  static Color black = HexColor("000000");
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
}

double getWp (context) {
  return MediaQuery.of(context).size.width / 392.7;
}

double getHp (context) {
  return MediaQuery.of(context).size.height / 781.1;
}

class WidthPixel {
  final double value;
  WidthPixel(this.value);
}

class HeightPixel {
  final double value;
  HeightPixel(this.value);
}