import 'package:flutter/material.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/tagOutline.dart';


class groupTitleCard extends StatefulWidget {
  String name;
  int memberCount;
  String description;
  String? image;
  String? hexColor;

  groupTitleCard({Key? key,
    required this.name,
    required this.memberCount,
    this.hexColor,
    required this.description,
    this.image,
  }) : super(key: key);

  @override
  _groupTitleCardState createState() => _groupTitleCardState();
}

class _groupTitleCardState extends State<groupTitleCard> {

  Image? groupImage;


  @override
  Widget build(BuildContext context) {

    double containerHeight= (MediaQuery.of(context).size.height)/10;

      if (widget.image!=null && widget.image!="") {
        var tempImage = Image.network(widget.image!);
        tempImage.image
            .resolve(ImageConfiguration())
            .addListener(ImageStreamListener((ImageInfo image, bool syncrhonousCall) {
          if (mounted) {
            setState(() => groupImage = tempImage);
          }
        }));
      }

    return Stack(
      children:[
        Column(
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(20.0, 8.0, 10.0, 8.0),
                height:containerHeight,
                color: ThemeColor.backgroundGrey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      flex:2,
                      child: Text(widget.name,
                        style: ThemeText.titleMedium(color: widget.hexColor != null ?
                          HexColor(widget.hexColor!): ThemeColor.black,
                          fontSize: 23,
                          ),
                        ),
                    ),
                    Spacer(flex:1),
                    ],
                  )
                ),
            Container(
                //height:containerHeight,
                padding: EdgeInsets.fromLTRB(20.0, 8.0, 10.0, 8.0),
                color:ThemeColor.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          flex:2,
                          child: Text(widget.description,
                            textHeightBehavior: TextHeightBehavior(),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: ThemeText.regularSmall(
                              color: ThemeColor.darkGrey,
                              fontSize:16, height: 1.3
                            ),
                          ),
                        ),
                        Spacer(flex:1),
                      ],
                    ),
                    SizedBox(height:18),
                    Row(
                      children: [
                        Text(
                          widget.memberCount.toString(), style: ThemeText.regularSmall(fontSize:16),
                        ),
                        SizedBox(width:5),
                        Icon(Icons.person, size: 20.0) ,
                        SizedBox(width:10),
                        tagOutline(textOnly: false, fillColor: ThemeColor.secondaryBlue,
                          borderColor: ThemeColor.secondaryBlue, height: 30,
                          padding: EdgeInsets.all(0.0),
                          widget:
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0.0),
                              textStyle: TextStyle(fontSize: 16,
                                color: ThemeColor.white,
                              ),
                            ),
                            onPressed: () {},
                            child: Text('+ Join',
                              style: ThemeText.regularSmall(fontSize:16,color:ThemeColor.white)
                            ),
                            ),
                          ),
                        Spacer(flex:1),
                        Text("sortby"),
                      ],
                    )
                  ],
                )
            ),
          ],
        ),

       groupImage!= null ?
       Positioned(
            top:containerHeight/2,
            right: (MediaQuery.of(context).size.width)/10,
            child: Container(
              width: containerHeight,
              height: containerHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: groupImage!.image,
                    fit: BoxFit.fill,
                  )
                ),
              ),
            ) : Container()
      ]
    );
  }
}
