import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/search_result.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/search/search_result_card.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';

import 'loading.dart';
import 'navbar.dart';

class Search2 extends StatefulWidget {
  final UserData userData;

  const Search2({Key? key, required this.userData}) : super(key: key);

  @override
  _Search2State createState() => _Search2State();
}

class _Search2State extends State<Search2> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<SearchResult> filteredResults = [];
  Icon _closeIcon = new Icon(Icons.close, color: Colors.black);
  Widget _appBarTitle = new Text('Loading');
  SearchResultType _resultType = SearchResultType.groups;
  Stream streamQuery = Stream.empty();
  List<DocumentReference> _allowableGroupRefs = [];

  GroupsDatabaseService _groups = GroupsDatabaseService();
  UserDataDatabaseService _userDataDatabase = UserDataDatabaseService();
  PostsDatabaseService _posts = PostsDatabaseService();

  _Search2State() {
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

          /*
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

         */


      ]
    );
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
                return SearchResultCard(searchResult: filteredResults[index], searchResultType: _resultType,);
              }
            );
          }
        }
      );
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
              streamQuery = _userDataDatabase.searchStream(_searchText);
            });
            break;
          case SearchResultType.posts:
            setState(() {
              streamQuery = _posts.searchStream(_searchText, _allowableGroupRefs);
            });
            break;
          default: // for ResultType.groups
            setState(() {
              streamQuery = _groups.searchStream(_searchText, _allowableGroupRefs);
            });
        }
      });
    }
  }


  void _getAllowableGroupIds() async {
    final temp = await _groups.getAllowableGroupRefs(
        domain: widget.userData.domain,
        county: widget.userData.county,
        state: widget.userData.state,
        country: widget.userData.country);
    setState(() {
      _allowableGroupRefs = temp;
    });
  }
}
