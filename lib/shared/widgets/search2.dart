import 'package:flutter/material.dart';
import 'package:hs_connect/models/search_result.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';

class Search2 extends StatefulWidget {
  const Search2({Key? key}) : super(key: key);

  @override
  _Search2State createState() => _Search2State();
}

class _Search2State extends State<Search2> {

  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<SearchResult> filteredResults = [];
  Icon _closeIcon = new Icon(Icons.close, color: Colors.black);
  Widget _appBarTitle = new Text('Loading');
  ResultType _resultType = ResultType.groups;
  Stream streamQuery = Stream.empty();

  GroupsDatabaseService _groups = GroupsDatabaseService();
  UserDataDatabaseService _userData = UserDataDatabaseService();
  PostsDatabaseService _posts = PostsDatabaseService();

  _Search2State() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = '';
          streamQuery = Stream.empty();
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
    this._getResults();
    setState(() {
      _appBarTitle = new TextField(
        controller: _filter,
        decoration: new InputDecoration(
            hintText: 'Search for ' + _resultType.toString()
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void _getResults() async {
    setState(() {
      switch (_resultType) {
        case ResultType.people:
          break;
        case ResultType.posts:
          break;
        default:
          // for ResultType.groups
      }
    });
  }
}
