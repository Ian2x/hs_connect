import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/screens/authenticate/wait_verification.dart';
import 'package:hs_connect/services/auth.dart';


class RegisterEmail extends StatefulWidget {
  final Function toggleView;

  const RegisterEmail({Key? key, required this.toggleView}) : super(key: key);

  @override
  _RegisterEmailState createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {

  final AuthService _auth = AuthService();
  String email = '';
  String error = '';
  bool loading = false;


  void handleError() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify your school email'),
        actions: <Widget>[
          TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('Register'),
              style: TextButton.styleFrom(
                primary: Colors.red[400],
              ),
              onPressed: () {
                widget.toggleView();
              })
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: 'Email'
              ),
              onChanged: (value) {
                setState(() {
                  email = value.trim();
                });
              },
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:[
                ElevatedButton(
                  child: Text('Verify'),
                  onPressed: () async {
                    setState(() => loading = true);
                    dynamic result =  await _auth.createEmailUser(email);

                    if (result is User?) {
                      final int tempIndex = email.lastIndexOf('@');
                      final String domain = email.substring(tempIndex);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WaitVerification(domain: domain)));
                    } else if (result is FirebaseAuthException) {
                      setState(() {
                        String errorMsg = '';
                        if (result.message != null) errorMsg += result.message!;
                        errorMsg += 'If you think this is a mistake, please contact us at ___ for support. [Error Code: ' + result.code + ']';
                        error = errorMsg;
                        loading = false;
                      });
                    } else {
                      setState(() {
                        error = 'ERROR: [' + result.toString() + ']. Please contact us at ___ for support.';
                        loading = false;
                      });
                    }
                  }
                )
              ]),
          SizedBox(height: 12.0),
          Text(
            error,
            style: TextStyle(color: Colors.red, fontSize: 14.0),
          )
        ],),
    );
  }
}
