import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../inputDecorations.dart';
import '../pixels.dart';

class AnimatedSwitch extends StatefulWidget {
  final bool initialState;
  final VoidFunction onToggle;
  const AnimatedSwitch({Key? key, required this.initialState, required this.onToggle}) : super(key: key);

  @override
  _AnimatedSwitchState createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<AnimatedSwitch> {
  late bool isEnabled;
  final animationDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    isEnabled = widget.initialState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: (){
        if (mounted) {
          setState((){
            isEnabled = !isEnabled;
          });
        }
        widget.onToggle();
      },
      child: AnimatedContainer(
        height: 28*hp,
        width: 50*wp,
        duration: animationDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15*hp),
          color: isEnabled ? colorScheme.secondary.withAlpha(255) : colorScheme.primary,
        ),
        child: AnimatedAlign(
          duration: animationDuration,
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3*wp),
            child: Container(
              width: 22*wp,
              height: 22*hp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedSwitch2 extends StatefulWidget {
  final bool initialState;
  final VoidFunction onToggle;
  const AnimatedSwitch2({Key? key, required this.initialState, required this.onToggle}) : super(key: key);

  @override
  _AnimatedSwitchState2 createState() => _AnimatedSwitchState2();
}

class _AnimatedSwitchState2 extends State<AnimatedSwitch2> {
  late bool isEnabled;
  final animationDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    isEnabled = widget.initialState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: (){
        if (mounted) {
          setState((){
            isEnabled = !isEnabled;
          });
        }
        widget.onToggle();
      },
      child: AnimatedContainer(
        height: 23*hp,
        width: 39*wp,
        duration: animationDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15*hp),
          color: isEnabled ? colorScheme.secondary.withAlpha(255) : colorScheme.primary,
        ),
        child: AnimatedAlign(
          duration: animationDuration,
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3*wp),
            child: Container(
              width: 17*wp,
              height: 17*hp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}