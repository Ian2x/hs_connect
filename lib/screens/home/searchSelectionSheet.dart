import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class SearchSelectionSheet extends StatefulWidget {
  final bool initialSearchByTrending;
  final VoidBoolParamFunction toggleSearch;

  const SearchSelectionSheet({Key? key, required this.initialSearchByTrending, required this.toggleSearch}) : super(key: key);

  @override
  _SearchSelectionSheetState createState() => _SearchSelectionSheetState();
}

class _SearchSelectionSheetState extends State<SearchSelectionSheet> {
  late bool searchByTrending;

  @override
  void initState() {
    searchByTrending = widget.initialSearchByTrending;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    final colorScheme = Theme.of(context).colorScheme;

    final double bottomSpace = max(MediaQuery.of(context).padding.bottom, 25);

    return Container(
      height: 176 + bottomSpace,
        padding: EdgeInsets.fromLTRB(25, 25, 25, bottomSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Filter your feed by:",
                    style: Theme.of(context).textTheme.headline6),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!searchByTrending && mounted) {
                  widget.toggleSearch(true);
                  setState(() {
                    searchByTrending = true;
                  });
                }
              },
              child: Column(
                children: [
                  Divider(),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hot', style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w500)),
                          SizedBox(height: 5),
                          Text("Show trending posts", style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary)),
                          SizedBox(height: 2)
                        ],
                      ),
                      Spacer(),
                      ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 40),
                          child:
                          Checkbox(
                            value: searchByTrending,
                            shape: CircleBorder(),
                            activeColor: colorScheme.secondary,
                            onChanged: (bool? value) {
                              if (value==true) {
                                if (!searchByTrending && mounted) {
                                  widget.toggleSearch(true);
                                  setState(() {
                                    searchByTrending = true;
                                  });
                                }
                              }
                            },
                          )
                      )
                    ],
                  )
                ],
              )
            ),
            GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (searchByTrending && mounted) {
                    widget.toggleSearch(false);
                    setState(() {
                      searchByTrending = false;
                    });
                  }
                },
                child: Column(
                  children: [
                    Divider(),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New', style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w500)),
                            SizedBox(height: 5),
                            Text("Show the newest posts", style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary)),
                            SizedBox(height: 2)
                          ],
                        ),
                        Spacer(),
                        ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 40),
                            child:
                            Checkbox(
                              value: !searchByTrending,
                              shape: CircleBorder(),
                              activeColor: colorScheme.secondary,
                              onChanged: (bool? value) {
                                if (value==true) {
                                  if (searchByTrending && mounted) {
                                    widget.toggleSearch(false);
                                    setState(() {
                                      searchByTrending = false;
                                    });
                                  }
                                }
                              },
                            )
                        )
                      ],
                    )
                  ],
                )
            )
          ],
        ));
  }
}