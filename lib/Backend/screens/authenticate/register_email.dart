import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/Backend/screens/authenticate/wait_verification.dart';
import 'package:hs_connect/Backend/services/auth.dart';


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
                    if (result == null) {
                      setState(() {
                        error = 'Each school email can only be used once. If you think this is a mistake, contact us at ___ for support.';
                        loading = false;
                      });
                    } else {
                      final int tempIndex = email.lastIndexOf('@');
                      final String domain = email.substring(tempIndex);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WaitVerification(domain: domain)));
                    }
                    /*
                    _auth.createEmailUser(email)
                        .then((_){
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WaitVerification()));
                        })
                        .catchError(handleError);

                     */
                  },
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
