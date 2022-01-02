import 'package:flutter/material.dart';
import 'package:hs_connect/models/search_result.dart';
import 'package:hs_connect/screens/home/post_feeds/specific_group_feed.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';
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
  Icon _closeIcon = new Icon(Icons.close, color: Colors.black);
  Widget _appBarTitle = new Text('Loading...');

  _SearchState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        if (mounted) {
          setState(() {
            _searchText = "";
            filteredResults = widget.searchResults;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchText = _filter.text;
          });
        }
      }
    });
  }

  @override
  void initState() {
    this._getNames();
    if (mounted) {
      setState(() {
        _appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              hintText: 'Search...'
          ),
        );
      });
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: _buildBody(),
      ),
      bottomNavigationBar: navbar(currentIndex: 1,),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return new AppBar(
      backgroundColor: HexColor('FFFFFF'),
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _closeIcon,
        onPressed: () {
          Navigator.pop(context);
        }
      ),
    );
  }

  Widget _buildBody() {
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
                MaterialPageRoute(builder: (context) =>
                    SpecificGroupFeed(groupRef: filteredResults[index].resultRef)), // GroupSearch()),
              );
            },
          );
        },
      );
    }


  void _getNames() async {
    if (mounted) {
      setState(() {
        filteredResults = widget.searchResults;
      });
    }
  }


}