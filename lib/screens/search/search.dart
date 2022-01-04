import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/search/searchResultCard.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

import '../../shared/widgets/loading.dart';
import '../../shared/widgets/navigationBar.dart';

class Search extends StatefulWidget {
  final UserData userData;

  const Search({Key? key, required this.userData}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<SearchResult> filteredResults = [];
  Icon _closeIcon = new Icon(Icons.close, color: Colors.black);
  Widget _appBarTitle = new Text('Loading');
  SearchResultType _resultType = SearchResultType.groups;
  Stream streamQuery = Stream.empty();
  List<DocumentReference> _allowableGroupRefs = [];

  _SearchState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        if (mounted) {
          setState(() {
            _searchText = '';
            streamQuery = Stream.empty();
          });
        }
      } else {
        _getResults();
      }
    });
  }

  @override
  void initState() {
    this._getResults();
    if (mounted) {
      setState(() {
        _appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(hintText: 'Search for ' + _resultType.string),
        );
      });
    }
    this._getAllowableGroupIds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: _buildBody(),
      ),
      bottomNavigationBar: navigationBar(
        currentIndex: 1,
      ),
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
            }),
        actions: <Widget>[
          DropdownButton<SearchResultType>(
            value: _resultType,
            items: SearchResultType.values
                .map((SearchResultType srt) => DropdownMenuItem<SearchResultType>(value: srt, child: Text(srt.string)))
                .toList(),
            onChanged: (SearchResultType? newValue) {
              if (mounted) {
                setState(() {
                  _resultType = newValue != null ? newValue : SearchResultType.groups;
                  _appBarTitle = new TextField(
                    controller: _filter,
                    decoration: new InputDecoration(hintText: 'Search for ' + _resultType.string),
                  );
                });
              }
            },
          ),
        ]);
  }

  Widget _buildBody() {
    if (!(_searchText.isEmpty)) {
      return StreamBuilder(
          stream: streamQuery,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loading();
            } else {
              final List<SearchResult> filteredResults = snapshot.data as List<SearchResult>;
              return ListView.builder(
                  itemCount: filteredResults.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context, int index) {
                    return SearchResultCard(
                      searchResult: filteredResults[index],
                      searchResultType: _resultType,
                      currUserRef: widget.userData.userRef,
                    );
                  });
            }
          });
    } else {
      return Container();
    }
  }

  void _getResults() {
    if (mounted) {
      setState(() {
        _searchText = _filter.text;
        switch (_resultType) {
          case SearchResultType.people:
            setState(() {
              streamQuery = UserDataDatabaseService(currUserRef: widget.userData.userRef).searchStream(_searchText);
            });
            break;
          case SearchResultType.posts:
            setState(() {
              streamQuery = PostsDatabaseService(currUserRef: widget.userData.userRef).searchStream(_searchText, _allowableGroupRefs);
            });
            break;
          default: // for ResultType.groups
            setState(() {
              streamQuery = GroupsDatabaseService(currUserRef: widget.userData.userRef).searchStream(_searchText, _allowableGroupRefs);
            });
        }
      });
    }
  }

  void _getAllowableGroupIds() async {
    final temp = await GroupsDatabaseService(currUserRef: widget.userData.userRef).getAllowableGroupRefs(
        domain: widget.userData.domain,
        county: widget.userData.county,
        state: widget.userData.state,
        country: widget.userData.country);
    setState(() {
      _allowableGroupRefs = temp;
    });
  }
}
