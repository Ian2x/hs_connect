import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/themeManager.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingsPage extends StatefulWidget {
  final bool initialIsLightTheme;
  final UserData currUserData;
  const SettingsPage({Key? key, required this.initialIsLightTheme, required this.currUserData}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String emptyFeedbackError = 'Can\'t send empty feedback';

  final _feedbackFormKey = GlobalKey<FormState>();
  late bool isLightTheme;
  String _feedbackText = '';
  String? feedbackError;
  bool feedbackLoading = false;

  @override
  void initState() {
    isLightTheme = widget.initialIsLightTheme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              SizedBox(width: 85*wp),
              Text("Settings"),
            ],
          ),
          elevation: 0,
          leading: myBackButtonIcon(context),
          bottom: PreferredSize(
              child: Container(
                decoration: BoxDecoration(
                    gradient: Gradients.blueRed()
                ),
                //color: colorScheme.primary,
                height: topGradientThickness*hp,
              ),
              preferredSize: Size.fromHeight(topGradientThickness*hp)),
        ),
        body: SingleChildScrollView(
          child: Container(
            //width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(isLightTheme ? "Light Mode" : "Dark Mode", style: Theme.of(context).textTheme.subtitle1),
                SizedBox(height: 12),
                ToggleSwitch(
                  minWidth: 50,
                  minHeight: 40,
                  initialLabelIndex: isLightTheme ? 1 : 0,
                  cornerRadius: 5,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  totalSwitches: 2,
                  doubleTapDisable: true,
                  changeOnTap: false,
                  icons: [
                    Icons.nightlight_round,
                    Icons.wb_sunny,
                  ],
                  iconSize: 30,
                  activeBgColors: [[Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.55)], [Colors.yellow.withOpacity(0.8), Colors.orange.withOpacity(0.85)]],
                  animate: true,
                  animationDuration: 100,
                  curve: Curves.linear,
                  onToggle: (index) async {
                    if (isLightTheme) {
                      theme.setDarkMode();
                    } else {
                      theme.setLightMode();
                    }
                    if (mounted) {
                      setState(() {
                        isLightTheme = !isLightTheme;
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                Divider(thickness: 1.5),
                SizedBox(height: 12),
                Text("Send feedback", style: Theme.of(context).textTheme.subtitle1),
                feedbackError != null
                    ? Container(
                    padding: EdgeInsets.only(top: 12*hp),
                    child: Text(feedbackError!, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: colorScheme.error)))
                    : SizedBox(height: 6),
                Form(
                  key: _feedbackFormKey,
                  child: Column(
                    children: [
                      Container(
                        decoration: ShapeDecoration(
                          color: colorScheme.background,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10*hp)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        child: TextFormField(
                          style: Theme.of(context).textTheme.subtitle1,
                          maxLines: null,
                          autocorrect: false,
                          decoration: InputDecoration(
                              hintStyle: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.primary), border: InputBorder.none, hintText: "What can we improve on..."),
                          onChanged: (val) {
                            setState(() => _feedbackText = val);
                            if (feedbackError == emptyFeedbackError) {
                              if (mounted) {
                                setState(() {
                                  feedbackError = null;
                                });
                              }
                            }
                          },
                        ),
                      ),
                      TextButton(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: ShapeDecoration(
                            color: colorScheme.onError,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10*hp),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.onError,
                                  width: 1*hp,
                                )),
                          ),
                          child: Text("Submit", style: Theme.of(context).textTheme.bodyText2)
                        ),
                        onPressed: () async {
                          // check feedback isn't empty
                          if (_feedbackText.isEmpty) {
                            if (mounted) {
                              setState(() {
                                feedbackError = emptyFeedbackError;
                              });
                            }
                            return;
                          }
                          if (_feedbackFormKey.currentState != null && _feedbackFormKey.currentState!.validate()) {
                            // set to loading screen
                            if (mounted) {
                              setState(() {
                                feedbackLoading = true;
                                _feedbackText = '';
                              });
                              }
                            }
                            await FirebaseFirestore.instance.collection(C.feedback).add({
                              C.feedbackText: _feedbackText,
                              C.creatorRef: widget.currUserData.userRef
                            });
                            if (mounted) {
                              setState(() {
                                feedbackLoading = false;
                              });
                            }
                          }
                      )
                    ],
                  ),
                ),
              ],
            )
          ),
        )
      ),
    );
  }
}
