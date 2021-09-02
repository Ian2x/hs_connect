
import 'package:flutter/material.dart';
import 'UserPost.dart';
import '../Widgets/PostCard.dart';


class SchoolPostList extends StatelessWidget {

  SchoolPostList({Key? key}) : super(key: key);

  List<UserPost> userPosts = [
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
    UserPost('Test1', "Mankind is like dogs, not gods - as long as you don't get mad they'll bite you - but stay mad and you'll never be bitten. Dogs don't respect humility and sorrow.", 'mercerhighschool', 'dildobaggins'),
  ];





  @override
  Widget build(BuildContext context) {


    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          //final DailyForecast dailyForecast = server.getDailyForecastsByID(index);
          return PostCard(userPost: userPosts[index]);
        }
        //can put named optional Parameters here?
      )
    );
  }
}
