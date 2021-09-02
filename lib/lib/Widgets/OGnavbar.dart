import 'package:flutter/material.dart';
import '../main.dart';

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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation:0.0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: const Icon(Icons.school, size: 18.0),
                onPressed: (){
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) => new MainScreen())
                  );
                },
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: const Icon(Icons.add, size: 18.0),
                onPressed: (){},
              ),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: const Icon(Icons.search_rounded, size: 18.0),
                onPressed: (){},
              ),
              label: 'Explore',
            ),
          ],
          selectedItemColor: Colors.blueAccent,
        )
    );
  }
}
