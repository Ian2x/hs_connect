import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class GroupSelectionSheet extends StatefulWidget {
  final List<Group> groups;
  final Group initialSelectedGroup;
  final VoidGroupParamFunction onSelectGroup;

  const GroupSelectionSheet({Key? key, required this.groups, required this.initialSelectedGroup, required this.onSelectGroup}) : super(key: key);

  @override
  _GroupSelectionSheetState createState() => _GroupSelectionSheetState();
}

class _GroupSelectionSheetState extends State<GroupSelectionSheet> {
  late Group selectedGroup;

  @override
  void initState() {
    selectedGroup = widget.initialSelectedGroup;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    final colorScheme = Theme.of(context).colorScheme;
    final double bottomSpace = max(MediaQuery.of(context).padding.bottom, 25);

    return Container(
        height: 167 + bottomSpace,
        padding: EdgeInsets.fromLTRB(25, 25, 25, bottomSpace),
        child: ListView.builder(
          itemCount: widget.groups.length + 1,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pick a circle",
                      style: Theme.of(context).textTheme.headline6),
                ],
              );
            } else {
              final group = widget.groups[index - 1];
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (mounted) {
                    setState(() {
                      selectedGroup = widget.groups[index - 1];
                    });
                  }
                  widget.onSelectGroup(widget.groups[index - 1]);
                },
                child: Column(
                  children: [
                    Divider(),
                    Row(children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name,
                              style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w500)),
                          group.name == "Public"
                              ? Column(
                                children: [
                                  SizedBox(height:5),
                                  Text("Anyone can see", style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary)),
                                  SizedBox(height:2),
                                ],
                              )
                              : Container(),
                          group.accessRestriction.restrictionType == AccessRestrictionType.domain
                              ? Column(
                                children: [
                                  SizedBox(height:5),
                                  Text("Only for your school", style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary)),
                                  SizedBox(height:2),
                                ],
                              )
                              : Container()
                        ],
                      ),
                      Spacer(),
                      ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 40),
                          child:
                          Checkbox(
                            value: selectedGroup == widget.groups[index - 1],
                            shape: CircleBorder(),
                            activeColor: colorScheme.secondary,
                            onChanged: (bool? value) {
                              if (value==true) {
                                if (mounted) {
                                  setState(() {
                                    selectedGroup = widget.groups[index - 1];
                                  });
                                }
                                widget.onSelectGroup(widget.groups[index - 1]);
                              }
                            },
                          )
                      )
                    ]),
                  ],
                ),
              );
            }
          },
        ));
  }
}