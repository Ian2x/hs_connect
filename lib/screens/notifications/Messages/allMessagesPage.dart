import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class AllMessagesPage extends StatefulWidget {
  const AllMessagesPage({Key? key}) : super(key: key);

  @override
  _AllMessagesPageState createState() => _AllMessagesPageState();
}

class _AllMessagesPageState extends State<AllMessagesPage> {
  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    }

    Set<DocumentReference> otherUsersRefs = new Set();
    otherUsersRefs.addAll(userData.userMessages.map((UM) => UM.otherUserRef));

    List<DocumentReference> OUR = otherUsersRefs.toList();
    return ListView.builder(
      itemCount: OUR.length,
      physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
        return Container();
        }
    );
  }
}
