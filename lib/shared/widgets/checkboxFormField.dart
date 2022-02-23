import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {Widget? title, FormFieldSetter<bool>? onSaved, FormFieldValidator<bool>? validator, bool initialValue = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: state.hasError,
                title: title,
                value: state.value,
                onChanged: state.didChange,
                contentPadding: EdgeInsets.zero,
                subtitle: state.hasError
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          state.errorText!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}

Color authCheckboxGetColor(Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return Colors.black;
  }
  return Color(0xFF13a1f0);
}

class AuthCheckboxFormField extends StatelessWidget {
  final bool termsAccepted;
  final VoidBoolParamFunction toggleTerms;

  const AuthCheckboxFormField({Key? key, required this.termsAccepted, required this.toggleTerms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Checkbox(
          value: termsAccepted,
          onChanged: (bool? value) {
            if (value == true) {
              toggleTerms(true);
            } else {
              toggleTerms(false);
            }
          },
          side: BorderSide(width: 1, color: Colors.black),
          fillColor: MaterialStateProperty.resolveWith(authCheckboxGetColor),
        ),
        RichText(
            maxLines: 3,
            text: TextSpan(style: textTheme.caption?.copyWith(color: Colors.black), children: [
              TextSpan(text: "I have read and agree to Convo's "),
              TextSpan(
                  text: "Terms\nof Service",
                  style: textTheme.caption?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch('https://www.getconvo.app/terms')) {
                        await launch('https://www.getconvo.app/terms');
                      }
                    }),
              TextSpan(text: ", "),
              TextSpan(
                  text: "Content Policy",
                  style: textTheme.caption?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch('https://www.getconvo.app/content')) {
                        await launch('https://www.getconvo.app/content');
                      }
                    }),
              TextSpan(text: ", and "),
              TextSpan(
                  text: "Privacy Policy",
                  style: textTheme.caption?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch('https://www.getconvo.app/privacy')) {
                        await launch('https://www.getconvo.app/privacy');
                      }
                    })
            ])),
      ],
    );
  }
}