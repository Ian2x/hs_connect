import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {Widget? title,
        FormFieldSetter<bool>? onSaved,
        FormFieldValidator<bool>? validator,
        bool initialValue = false})
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
            builder: (BuildContext context) =>  Text(
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

CheckboxFormField myCheckBoxFormField(TextTheme textTheme) {
  return CheckboxFormField(
      validator: (val) {
        if (val == false) {
          return "Must read and agree to Circles.co's terms and policies";
        } else
          return null;
      },
      title: FittedBox(
        child: RichText(
            maxLines: 3,
            text: TextSpan(
                style: textTheme.caption?.copyWith(color: Colors.black),
                children: [
                  TextSpan(text: "I have read and agree to Circles.co's "),
                  TextSpan(
                      text: "Terms\nof Service",
                      style: textTheme.caption
                          ?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () async {
                          if (await canLaunch('https://www.getcircles.co/terms')) {
                            await launch('https://www.getcircles.co/terms');
                          }
                        }),
                  TextSpan(text: ", "),
                  TextSpan(text: "Content Policy",
                      style: textTheme.caption
                          ?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () async {
                          if (await canLaunch('https://www.getcircles.co/content')) {
                            await launch('https://www.getcircles.co/content');
                          }
                        }
                  ),
                  TextSpan(text: ", and "),
                  TextSpan(text: "Privacy Policy",
                      style: textTheme.caption
                          ?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () async {
                          if (await canLaunch('https://www.getcircles.co/privacy')) {
                            await launch('https://www.getcircles.co/privacy');
                          }
                        }
                  )
                ])),
      ));
}
