import 'package:flutter/material.dart';

import 'package:hover_ussd/hover_ussd.dart';
import 'package:android_intent/android_intent.dart';

class testPay extends StatefulWidget {
  @override
  _testPayState createState() => _testPayState();
}

class _testPayState extends State<testPay> {
  final HoverUssd _hoverUssd = HoverUssd();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Row(
            children: [
              FlatButton(
                onPressed: () {
                  final AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      package: "com.android.stk");
                  intent.launch();
                },
                child: Text("Start Transaction"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}