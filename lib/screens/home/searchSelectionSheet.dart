import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class SearchSelectionSheet extends StatefulWidget {
  final bool initialSearchByTrending;
  final VoidFunction toggleSearch;

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

    return Container(
      height: 208*hp,
        padding: EdgeInsets.fromLTRB(25*wp, 25*hp, 25*wp, 25*hp),
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
                  widget.toggleSearch();
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
                          Text('Hot', style: Theme.of(context).textTheme.subtitle1),
                          SizedBox(height: 5*hp),
                          Text("Sort posts by newest", style: Theme.of(context).textTheme.subtitle2),
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
                            onChanged: (bool? value) {
                              if (value==true) {
                                if (!searchByTrending && mounted) {
                                  widget.toggleSearch();
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
                    widget.toggleSearch();
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
                            Text('New', style: Theme.of(context).textTheme.subtitle1),
                            SizedBox(height: 5*hp),
                            Text("Sort posts by newest", style: Theme.of(context).textTheme.subtitle2),
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
                              onChanged: (bool? value) {
                                if (value==true) {
                                  if (searchByTrending && mounted) {
                                    widget.toggleSearch();
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