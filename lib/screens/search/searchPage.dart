import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/search/discover.dart';
import 'package:hs_connect/shared/noAnimationMaterialPageRoute.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/navigationBar.dart';
import 'package:hs_connect/screens/search/search.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Icon _searchIcon = new Icon(Icons.search, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    if (userData == null) {
      return Loading();
    }

    return Scaffold(
      backgroundColor: HexColor("#E9EDF0"),
      appBar: AppBar(
        backgroundColor: HexColor('FFFFFF'),
        title: Text('test'),
        leading: new IconButton(
          icon: _searchIcon,
          onPressed: () {
            Navigator.push(
              context,
              NoAnimationMaterialPageRoute(builder: (context) => Search(userData: userData)),
            );
          },
        ),
      ),
      body: Discover(),
      bottomNavigationBar: navigationBar(
        currentIndex: 1,
      ),
    );
  }
}
