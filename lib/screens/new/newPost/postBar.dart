import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

class postBar extends StatelessWidget {
  const postBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: HexColor("E9EDF0"),
      child: Row(
        children: [
          SizedBox(width: 40),
          IconButton(
            icon: Icon(Icons.image_outlined),
            color: HexColor("223e52"),
            iconSize: 20.0,
            onPressed: () {},
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 3.0, 0.0),
            decoration: ShapeDecoration(
              color: HexColor('FFFFFF'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0),
                  side: BorderSide(
                    color: HexColor("E9EDF0"),
                    width: 3.0,
                  )),
            ),
            child: Text("+Add a Tag "),
          ),
        ],
      ),
    );
  }
}
