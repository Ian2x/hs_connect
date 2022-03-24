import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:provider/provider.dart';

import '../../../models/userData.dart';

class GroupSelectionSheet extends StatefulWidget {
  final List<Group> groups;
  final Group initialSelectedGroup;
  final VoidGroupParamFunction onSelectGroup;

  const GroupSelectionSheet(
      {Key? key, required this.groups, required this.initialSelectedGroup, required this.onSelectGroup})
      : super(key: key);

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
    final textTheme = Theme.of(context).textTheme;
    final double bottomSpace = max(MediaQuery.of(context).padding.bottom, 25);
    final userData = Provider.of<UserData?>(context, listen: false);
    final activeColor = userData?.domainColor ?? colorScheme.secondary;

    return Container(
        height: 185 + bottomSpace,
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
                  Text("Who can view?", style: textTheme.headline6),
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
                          Row(
                            children: [
                              Text(group.name,
                                  style: textTheme.headline6),
                              group.accessRestriction.restrictionType == AccessRestrictionType.domain ? SizedBox(width: 3) : Container(),
                              group.accessRestriction.restrictionType == AccessRestrictionType.domain ? Icon(Icons.lock, size: 14) : Container()
                            ],
                          ),
                          group.name == "Public"
                              ? Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Text("Anyone can see",
                                        style: textTheme
                                            .subtitle1
                                            ?.copyWith(color: colorScheme.primary)),
                                    SizedBox(height: 2),
                                  ],
                                )
                              : Container(),
                          group.accessRestriction.restrictionType == AccessRestrictionType.domain
                              ? Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Text("Only for your school",
                                        style: textTheme
                                            .subtitle1
                                            ?.copyWith(color: colorScheme.primary)),
                                    SizedBox(height: 2),
                                  ],
                                )
                              : Container()
                        ],
                      ),
                      Spacer(),
                      ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 40),
                          child: Checkbox(
                            value: selectedGroup == widget.groups[index - 1],
                            shape: CircleBorder(),
                            activeColor: activeColor,
                            onChanged: (bool? value) {
                              if (value == true) {
                                if (mounted) {
                                  setState(() {
                                    selectedGroup = widget.groups[index - 1];
                                  });
                                }
                                widget.onSelectGroup(widget.groups[index - 1]);
                              }
                            },
                          ))
                    ]),
                  ],
                ),
              );
            }
          },
        ));
  }
}
