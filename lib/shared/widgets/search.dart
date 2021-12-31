import 'package:flutter/material.dart';
import 'package:hs_connect/models/search_result.dart';
import 'package:hs_connect/screens/home/post_feeds/specific_group_feed.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/widgets/navbar.dart';

class Search extends StatefulWidget {
  final List<SearchResult> searchResults;
  const Search({Key? key, required this.searchResults}) : super(key: key);

  @override
  _SearchState createState() => new _SearchState();
}

class _SearchState extends State<Search> {
  // final formKey = new GlobalKey<FormState>();
  // final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<SearchResult> filteredResults = [];
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('DiscoverGroups');

  _SearchState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredResults = widget.searchResults;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    this._getNames();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: _buildList(),
      ),
      bottomNavigationBar: navbar(),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List<SearchResult> tempList = [];
      for (int i = 0; i < widget.searchResults.length; i++) {
        if (widget.searchResults[i].resultText.toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(widget.searchResults[i]);
        }
      }
      filteredResults = tempList;
    }
    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredResults[index].resultText),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SpecificGroupFeed(groupRef: filteredResults[index].resultRef)),// GroupSearch()),
            );
            print(filteredResults[index].resultText);
          },
        );
      },
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text( 'Search Example' );
        filteredResults = widget.searchResults;
        _filter.clear();
      }
    });
  }

  void _getNames() async {

    setState(() {
      filteredResults = widget.searchResults;
    });

  }


}