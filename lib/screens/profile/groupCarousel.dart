import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/groupView/groupPage.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:provider/provider.dart';


const circlesViewportFraction = 0.25;
const blocksViewportFraction = 0.6;
const instant = Duration(milliseconds: 1); // milliseconds
const circlesHeight = 75.0;
const circlesWidth = 75.0;
const blocksHeight = 200.0;
const blocksWidth = 200.0;
const circleSizeFactor = 0.5; // bigger = more different
const blockSizeFactor = 0.0; // bigger = more different

class GroupCarousel extends StatefulWidget {
  final List<Group> groups;

  GroupCarousel({required this.groups});

  @override
  _GroupCarouselState createState() => new _GroupCarouselState();
}

class _GroupCarouselState extends State<GroupCarousel> {
  late PageController circlesController;
  late PageController blocksController;
  int? currentPage;
  int initialPage = 0;
  // This makes sure the animation only runs once
  bool initialized = false;
  List<Widget> circlesContent = [];
  static const defaultCirclesContent = Image(image: AssetImage('assets/masonic-G.png'));

  // Handle time
  late Timer timer;

  @override
  initState() {
    timer = Timer(Duration(milliseconds: 100), () => setState(() {}));
    super.initState();
    while (initialPage < 50) {
      initialPage+=widget.groups.length;
    }
    circlesController = PageController(
      initialPage: initialPage,
      keepPage: false,
      viewportFraction: circlesViewportFraction,
    );
    blocksController = PageController(
      initialPage: initialPage,
      keepPage: false,
      viewportFraction: blocksViewportFraction,
    );
    circlesController.addListener(onCirclesScroll);
    for (int i=0; i<widget.groups.length; i++) {
      bool textCircle = widget.groups[i].image==null || widget.groups[i].image=='';
      if (textCircle) {
        String s = widget.groups[i].name;
        int sLen = s.length;
        String initial = "?";
        for (int j=0; j<sLen; j++) {
          if (RegExp(r'[a-z]').hasMatch(widget.groups[i].name[j].toLowerCase())) {
            initial = widget.groups[i].name[j].toUpperCase();
            break;
          }
        }
        circlesContent.add(Text(initial));
      } else {
        circlesContent.add(defaultCirclesContent);
        var tempImage = Image.network(widget.groups[i].image!);
        tempImage.image
            .resolve(ImageConfiguration())
            .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall)
        {
          if (mounted) {
            var newCirclesContent = circlesContent;
            newCirclesContent[i] = tempImage;
            setState(() => circlesContent = newCirclesContent);
          }
        }));
      }
    }
  }

  void onCirclesScroll() {
    if (circlesController.page==null) return;
    if (circlesController.page!<=5.1) {
      circlesController.animateToPage(circlesController.page!.toInt() + initialPage, duration: instant, curve: Curves.linear);
    }
    blocksController.animateToPage(circlesController.page!.round(), duration: Duration(milliseconds: 150), curve: Curves.linear);

  }

  @override
  dispose() {
    timer.cancel();
    circlesController.dispose();
    blocksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!timer.isActive && !initialized) {
      circlesController.animateToPage(initialPage, duration: instant, curve: Curves.linear);
      blocksController.animateToPage(initialPage, duration: instant, curve: Curves.linear);
      initialized = true;
    }


    return Container(
      height: 400,
      child: Column(children: <Widget>[
        Container(
            height: circlesHeight,
            child: Overlay(
              initialEntries: [
                OverlayEntry(builder: (BuildContext context) {
                  return PageView.builder(
                      onPageChanged: (value) {
                        setState(() {
                          currentPage = value;
                        });
                      },
                      pageSnapping: true,
                      controller: circlesController,
                      itemBuilder: (context, index) => circlesBuilder(index));
                }),
                OverlayEntry(builder: (BuildContext context) {
                  return Row(children: <Widget>[
                    SizedBox(width: 12),
                    Icon(Icons.chevron_left, size: 40, color: Colors.black),
                    Spacer(),
                    Icon(Icons.chevron_right, size: 40, color: Colors.black),
                    SizedBox(width: 12),
                  ]);
                })
              ],
            )),
        SizedBox(height: 10),
        Divider(thickness: 1.5),
        SizedBox(height: 20),
        Container(
            height: blocksHeight,
            child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                pageSnapping: true,
                controller: blocksController,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => blocksBuilder(index))),
        Spacer(),
      ]),
    );
  }

  circlesBuilder(int index) {
    final trueIndex = index % widget.groups.length;
    Widget localContent = defaultCirclesContent;
    if (circlesContent.length>trueIndex) {
      localContent = circlesContent[trueIndex];
    }
    return AnimatedBuilder(
      animation: circlesController,
      builder: (context, child) {
        double value = 1.0;
        if (circlesController.position.haveDimensions) {
          value = circlesController.page! - index;
          value = (1 - (value.abs() * circleSizeFactor)).clamp(1-circleSizeFactor, 1.0);
        }

        return Center(
          child: SizedBox(
            height: Curves.easeOut.transform(value) * circlesHeight,
            width: Curves.easeOut.transform(value) * circlesHeight,
            child: child,
          ),
        );
      },
      child: Container(
        // margin: const EdgeInsets.all(8.0),
        // color: index % 2 == 0 ? Colors.blue : Colors.red,
        child: CircleButton(
          onTap: () {},
          child: localContent,
          textBackgroundColor: translucentColorFromString(widget.groups[trueIndex].name),
        )

      ),
    );
  }

  blocksBuilder(int index) {
    final trueIndex = index % widget.groups.length;
    return AnimatedBuilder(
      animation: blocksController,
      builder: (context, child) {
        double value = 1.0;
        if (blocksController.position.haveDimensions) {
          value = blocksController.page! - index;
          value = (1 - (value.abs() * blockSizeFactor)).clamp(1-blockSizeFactor, 1.0);
        }

        return Center(
          child: SizedBox(
            height: Curves.easeOut.transform(value) * blocksHeight,
            width: Curves.easeOut.transform(value) * blocksWidth,
            child: child,
          ),
        );
      },
      child: Container(
        // margin: const EdgeInsets.all(8.0),
        // color: index % 2 == 0 ? Colors.blue : Colors.red,
          child: BlockBlurb(group: widget.groups[trueIndex]),

      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget child;
  final Color textBackgroundColor;

  const CircleButton({Key? key, required this.onTap, required this.child, required this.textBackgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: textBackgroundColor,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        image: child is Image ? DecorationImage(
          fit: BoxFit.fill,
          image: (child as Image).image,
        ) : null,
      ),
      child: child is Image ? null : Center(child: child)
    );
  }
}

class BlockBlurb extends StatelessWidget {
  final Group group;
  const BlockBlurb({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);

    return Container(
      width: 200,
      height: 200,
      decoration: ShapeDecoration(
        color: HexColor('FFFFFF'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
            side: BorderSide(
              color: HexColor("E9EDF0"),
              width: 3.0,
            )),
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 18),
            Text(group.name, style:
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:5),
            Row(
              children: <Widget>[
                Spacer(),
                Text(group.numMembers.toString(), style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
                Text(" People", style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                )),
                Spacer()
              ]
            ),
            SizedBox(height:2),
            Spacer(),
            group.description != null ? Text(group.description!): Container(),
            Spacer(),
            Row(
              children: <Widget>[
                Spacer(),
            IconButton(
              icon: Icon(Icons.zoom_out_map),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupPage(
                        groupRef: group.groupRef,
                        currUserRef: userData!.userRef,
                      ),
                    ));
              },
            )
              ]
            )
          ]
        )
      )
    );
  }
}