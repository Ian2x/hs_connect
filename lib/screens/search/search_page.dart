import 'package:flutter/material.dart';
import 'package:hs_connect/screens/search/discover.dart';
import 'package:hs_connect/screens/search/search_bar.dart';
import 'package:hs_connect/shared/no_animation_material_page_route.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';
import 'package:hs_connect/shared/widgets/navbar.dart';
import 'package:hs_connect/shared/widgets/search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  Icon _searchIcon = new Icon(Icons.search, color: Colors.black);

  @override
  Widget build(BuildContext context) {
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
              NoAnimationMaterialPageRoute(builder: (context) => Search(searchResults: [])),
            );
          },
        ),
      ),
      body: Discover(),
      bottomNavigationBar: navbar(
        currentIndex: 1,
      ),
    );
  }
}
