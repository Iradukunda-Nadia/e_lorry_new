import 'package:flutter/material.dart';

import 'package:hover_ussd/hover_ussd.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

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
                  _hoverUssd.sendUssd(
                      actionId :"cfb31b12", extras: {});
                },
                child: Text("Start Transaction"),
              ),
              StreamBuilder(
                stream: _hoverUssd.onTransactiontateChanged,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == TransactionState.succesfull) {
                    return Text("succesfull");
                  } else if (snapshot.data == TransactionState.waiting) {
                    return Text("pending");
                  } else if (snapshot.data == TransactionState.failed) {
                    return Text("failed");
                  }
                  return Text("no transaction");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}