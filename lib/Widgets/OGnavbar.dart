import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/screens/explore/explore.dart';

import 'package:hs_connect/Backend/screens/new_post/new_post.dart';
import 'package:hs_connect/Tools/HexColor.dart';

class OGnavbar extends StatefulWidget {
  const OGnavbar({Key? key}) : super(key: key);

  @override
  _OGnavbarState createState() => _OGnavbarState();
}

class _OGnavbarState extends State<OGnavbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
            BoxShadow(
              color: HexColor("#111111"),
              spreadRadius: 1.0,
            ),
          ],
        ),
        child:  BottomNavigationBar(
          backgroundColor: HexColor("#000000"),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: IconButton(
                padding: EdgeInsets.zero,
                color: Colors.white,
                constraints: BoxConstraints(),
                icon: const Icon(Icons.school, size: 18.0),
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                padding: EdgeInsets.zero,
                color: Colors.white,
                constraints: BoxConstraints(),
                icon: const Icon(Icons.add, size: 18.0),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewPost()),
                  );
                },
              ),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                padding: EdgeInsets.zero,
                color: Colors.white,
                constraints: BoxConstraints(),
                icon: const Icon(Icons.search_rounded, size: 18.0),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Explore()),
                  );
                },
              ),
              label: 'Explore',
            ),
          ],
        ),
    );
  }
}
