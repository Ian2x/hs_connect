import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

class ModalBottomSheet extends StatefulWidget {
  final List<Group> groups;
  final Group initialSelectedGroup;
  final VoidGroupParamFunction onSelectGroup;

  const ModalBottomSheet({Key? key, required this.groups, required this.initialSelectedGroup, required this.onSelectGroup}) : super(key: key);

  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {

  Group? selectedGroup;

  @override
  void initState() {
    selectedGroup = widget.initialSelectedGroup;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedGroup==null) return Loading();
    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              itemCount: widget.groups.length + 1,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Text("Pick a group",
                          style: ThemeText.groupBold(
                            color: ThemeColor.black,
                            fontSize: 18,
                          )),
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
                          widget.onSelectGroup(widget.groups[index - 1]);
                        });
                      }
                    },
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(color: ThemeColor.backgroundGrey, thickness: 2),
                          Row(
                            children: <Widget>[
                              Text(group.name,
                                  style: ThemeText.groupBold(
                                    color: ThemeColor.darkGrey,
                                    fontSize: 16,
                                  )),
                              Spacer(),
                              ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 40),
                                child:
                                Checkbox(
                                  value: selectedGroup == widget.groups[index - 1],
                                  onChanged: (bool? value) {
                                    if (value==true) {
                                      if (mounted) {
                                        setState(() {
                                          selectedGroup = widget.groups[index - 1];
                                        });
                                      }
                                    }
                                  },
                                )
                              )
                            ]
                          ),
                          group.name == "Public"
                              ? Text("Anyone can see", style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize: 16))
                              : Container(),
                          group.accessRestriction.restrictionType == AccessRestrictionType.domain
                              ? Text("Only for your school", style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize: 16))
                              : Container()
                        ]
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ));
  }
}