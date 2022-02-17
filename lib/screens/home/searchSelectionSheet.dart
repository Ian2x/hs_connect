import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    final bottomSpace = max(MediaQuery.of(context).padding.bottom+1, 25*hp);

    return Container(
      height: 167*hp + bottomSpace,
        padding: EdgeInsets.fromLTRB(25*wp, 25*hp, 25*wp, bottomSpace),
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
                          SizedBox(height: 5*hp),
                          Text("Show trending posts", style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary)),
                          SizedBox(height: 2*hp)
                        ],
                      ),
                      Spacer(),
                      ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 40*hp),
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
                            SizedBox(height: 5*hp),
                            Text("Show the newest posts", style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary)),
                            SizedBox(height: 2*hp)
                          ],
                        ),
                        Spacer(),
                        ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 40*hp),
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