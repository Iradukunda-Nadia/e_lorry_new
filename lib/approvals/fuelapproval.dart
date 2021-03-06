import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_lorry/mechanic/Requests/fuel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chat.dart';
import 'package:hover_ussd/hover_ussd.dart';

final HoverUssd _hoverUssd = HoverUssd();

class FuelApproval extends StatefulWidget {
  @override
  _FuelApprovalState createState() => _FuelApprovalState();
}

class _FuelApprovalState extends State<FuelApproval> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

//We have two private fields here
  initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();

  }

  String userCompany;
  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
    });

  }

  String Pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fuel Requests"),
        actions: <Widget>[

          new Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              new IconButton(icon: new Icon(Icons.chat,
                color: Colors.white,)
                  , onPressed: (){
                    Navigator.of(context).push(new CupertinoPageRoute(
                        builder: (BuildContext context) => new Chat()
                    ));
                  }),

            ],
          )
        ],
      ),
      body: Items(),
    );
  }
}

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}


class _ItemsState extends State<Items> {

  initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();

  }

  String userCompany;
  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
    });

  }
  CollectionReference collectionReference =
  Firestore.instance.collection("fuelRequest");

  DocumentSnapshot _currentDocument;

  _updateData() async {
    await Firestore.instance
        .collection('fuelRequest')
        .document(_currentDocument.documentID)
        .updateData({'status': "checked"});
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: collectionReference.where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading... Please wait"),
              );
            } if (snapshot.data == null){
              return Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 100,
                        child: Image.asset('assets/empty.png'),
                      ),
                    ),
                    Text("The are no pending requests"),
                  ],
                ),);
            }
            else{
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data.documents[index];
                  return Container(
                    decoration: doc.data['status'] == 'pending' ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                          BoxShadow(
                            color: Colors.green,
                            spreadRadius: -4,
                            blurRadius: 5,
                            offset: Offset(0, 0),
                          )
                        ]): BoxDecoration(),
                    child: Card(
                      child: ListTile(
                        title: Text(doc.data["Truck"]),
                        subtitle: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  doc.data["date"],
                                  style: new TextStyle(color: Colors.grey, fontSize: 12.0,),
                                )
                              ],
                            ),
                            new Text(
                              doc.data["time"],
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        trailing: new Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.red[900])
                          ),
                          child: Text(doc.data['status'], style: TextStyle(color: Colors.red[900]),),
                        ),
                        onTap: () async {
                          setState(() {
                            _currentDocument = doc;
                          });

                          Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new AppFuel(

                            truck: doc.data["Truck"],
                            currLts: doc.data["Current litres"],
                            date: doc.data["date"],
                            ppl: doc.data["Price per liter"],
                            recepient: doc.data["Receipent"],
                            reqFuel: doc.data["Requested fuel"],
                            till: doc.data["Till"],
                            total: doc.data["Total"],
                            fStation: doc.data["FuelStaion"],
                            status: doc.data["status"],
                            reqBy: doc.data["reqby"],
                            itemID: doc.documentID,
                            image: doc.data["image"],
                            newLtrs: doc.data['New Fuel reading'],
                            payMethod: doc.data['payMethod'],
                            acc: doc.data['accNo'],
                            userC: doc.data['company'],
                            token: doc.data['token']


                          )));
                        },
                      ),
                    ),
                  );

                },
              );

            }
          }),

    );

  }
}

class AppFuel extends StatefulWidget {
  String currLts;
  String reqFuel;
  String ppl;
  String total;
  String fStation;
  String till;
  String recepient;
  String date;
  String status;
  String truck;
  String reqBy;
  String itemID;
  String image;
  String newLtrs;
  String payMethod;
  String acc;
  String userC;
  String token;



  AppFuel({
    this.payMethod,
    this.acc,
    this.userC,

    this.currLts,
    this.truck,
    this.reqFuel,
    this.recepient,
    this.ppl,
    this.total,
    this.fStation,
    this.till,
    this.date,
    this.status,
    this.reqBy,
    this.itemID,
    this.image,
    this.newLtrs,
    this.token,

  });
  @override
  _AppFuelState createState() => _AppFuelState();
}

class _AppFuelState extends State<AppFuel> {
  final formKey = GlobalKey<FormState>();
  final fKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _comment;
  String appQuote;
  String appPrice;
  String Pin;
  var pinCode = TextEditingController();
String userComp ;

  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('user');
      userComp = prefs.getString('company');
    });

  }

  void _approveCommand() {
    //get state of our Form
    _updateStatus();
    _show();

  }

  @override
  initState() {
    getStringValue();
    super.initState();
  }

  _updateStatus() async {
    await Firestore.instance
        .collection('fuelRequest')
        .document(widget.itemID)
        .updateData({
      'status': "Approved",
      'comment': "Approved",
      'approved by': currentUserEmail,
    });
  }

  void _sendApproval() {
    final form = fKey.currentState;
    form.reset();

  }

  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      _updateComment();
      _updateData();
      _showRequest();

    }
  }


  _updateData() async {
    await Firestore.instance
        .collection('fuelRequest')
        .document(widget.itemID)
        .updateData({'status': "Manager Comment"});
  }

  _updateComment() async {
    await Firestore.instance
        .collection('fuelRequest')
        .document(widget.itemID)
        .updateData({
      'comment': _comment,
    });
  }

  void _show() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text("Your Have Approved this request"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRequest() {
    _updateData();
    // flutter defined function
    final form = formKey.currentState;
    form.reset();


  }
  String radioItem = '';
  bool isApproval = false;
  bool showApproval = false;

  var msg = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text("Item Detail"),
        centerTitle: true,
      ),

      body: new Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          new Container(
            height: 200.0,
            decoration: new BoxDecoration(
              color: Colors.grey.withAlpha(50),
              borderRadius: new BorderRadius.only(
                bottomRight: new Radius.circular(100.0),
                bottomLeft: new Radius.circular(100.0),
              ),
            ),
          ),
          new SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: new Column(
              children: <Widget>[
                new SizedBox(
                  height: 20.0,
                ),
                new Card(
                  child: new Container(
                    margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: new Text(
                            "Details",
                            style: new TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                          ),
                        ),
                        new SizedBox(
                          height: 5.0,
                        ),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Truck",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.truck,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        new SizedBox(
                          height: 5.0,
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Request By",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.reqBy,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        new SizedBox(
                          height: 5.0,
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Current Litres",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.currLts,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),


                        new SizedBox(
                          height: 5.0,
                        ),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Fuel Requested",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.reqFuel,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),

                        new SizedBox(
                          height: 5.0,
                        ),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Price Per Litre",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.ppl,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),






                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Fuel Station",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.fStation,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        new SizedBox(
                          height: 5.0,
                        ),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Total",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.total,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        new SizedBox(
                          height: 5.0,
                        ),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  widget.payMethod,
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.till,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        widget.payMethod == 'phone'? new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Recepient",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.recepient,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ): new Offstage(),
                        widget.payMethod == 'Paybill'? new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Account No",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.acc,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ): new Offstage(),

                        new SizedBox(
                          height: 5.0,
                        ),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Text(
                                  "Date",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.date,
                              style: new TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),




                        new SizedBox(
                          height: 10.0,
                        ),

                        new Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.red[900])
                          ),
                          child: Text(widget.status, style: TextStyle(color: Colors.red[900]),),
                        ),


                      ],
                    ),
                  ),
                ),

                new SizedBox(
                  height: 10.0,
                ),
                widget.status == "pending"?
                Column(
                  children: [
                    new Card(
                      child: new Container(
                        margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new SizedBox(
                              height: 5.0,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              if (widget.payMethod == 'Till') {
                                                _hoverUssd.sendUssd(
                                                  actionId :"0466d73d", extras: { 'tillNo': widget.till, "amount": widget.total});
                                              }
                                              if (widget.payMethod == 'Paybill') {
                                                _hoverUssd.sendUssd(
                                                  actionId :"ec8d62b1", extras: { 'businessNo': widget.till, "AcNumber": widget.acc, "amount": widget.total});
                                              }
                                              if (widget.payMethod == 'Phone') {
                                                _hoverUssd.sendUssd(
                                                  actionId :"8176f539", extras: { 'phoneNumber': widget.till, "amount": widget.total});
                                              }




                                            },
                                            child: Text('Mpesa Prompt',
                                            style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'SFUIDisplay',
                                            fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                            color: Colors.white,
                                            elevation: 16.0,
                                            height: 50,
                                            textColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20)
                                            ),
                                            ),
                                            ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0), child: new Text('Use this option, \n To pay directly', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, ),),
                                        ),
                                      ],
                                    ),


                                  ],
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Column(
                                    children: [
                                      MaterialButton(
                                        onPressed: (){
                                          final AndroidIntent intent = AndroidIntent(
                                              action: 'action_view',
                                              package: "com.android.stk");
                                          intent.launch();
                                        },
                                        child: Text('STK Menu',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'SFUIDisplay',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        color: Colors.white,
                                        elevation: 16.0,
                                        height: 50,
                                        textColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0), child: new Text('Incase of an error, \n Write down the details and use this', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, ),),
                                      ),

                                    ],
                                  ),


                                ),


                              ],
                            ),
                                new SizedBox(
                                height: 5.0,
                                ),

                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: MaterialButton(
                        onPressed: () async {
                          showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoActionSheet(
                                    title: Text(
                                        "Enter your M-Pesa confirmation message"),
                                    message: Column(
                                      children: <Widget>[
                                        TextField(
                                          controller: msg,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      CupertinoButton(
                                        child: Text("Send"),
                                        onPressed: () {
                                          Firestore.instance.collection('messages')
                                              .add({
                                            'text': msg.text,
                                            'imageUrl': null,
                                            'senderName': currentUserEmail ,
                                            'senderPhotoUrl': '',
                                            'time': DateTime.now(),
                                            'company': userComp,
                                            'token': widget.token,
                                            'payment': 'Fuel',

                                          });
                                          Firestore.instance.collection('combined')
                                              .add({
                                            'fuel': widget.total,
                                            'company': userComp,
                                            'comment': 'Approved',
                                            'truck': widget.truck,
                                            "date" : DateFormat(' yyyy- MM - dd').format(DateTime.now()),
                                            "month" : DateFormat(' yyyy- MM').format(DateTime.now()),
                                            'timestamp': DateTime.now(),


                                          });
                                          _approveCommand();
                                        },
                                      )
                                    ],
                                  ));


                        },

                        child: Text('Paste Payment confirmation',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'SFUIDisplay',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        color: Colors.white,
                        elevation: 16.0,
                        height: 50,
                        textColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                    )

                  ],
                ): new Offstage(),

                new SizedBox(
                  height: 5.0,
                ),

                widget.userC == 'test'? Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: MaterialButton(
                    onPressed: () async {

                      if (widget.payMethod == 'Till') {
                        _hoverUssd.sendUssd(
                            actionId :"0466d73d", extras: { 'tillNo': widget.till, "amount": widget.total});
                      }
                      if (widget.payMethod == 'Paybill') {
                        _hoverUssd.sendUssd(
                            actionId :"ec8d62b1", extras: { 'businessNo': widget.till, "AcNumber": widget.acc, "amount": widget.total});
                      }
                      if (widget.payMethod == 'Phone') {
                        _hoverUssd.sendUssd(
                            actionId :"3ceaf856", extras: { 'phoneNumber': widget.till, "amount": widget.total});
                      }

                    },

                    child: Text('Approve And pay?',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'SFUIDisplay',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.white,
                    elevation: 16.0,
                    height: 50,
                    textColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                  ),
                ): new Offstage(),

                new SizedBox(
                  height: 5.0,
                ),



                widget.status == "Refilled"?
                new Card(
                  child: new Container(
                    margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new SizedBox(
                                    width: 5.0,
                                  ),
                                  new Text(
                                    "Total Litres Post Refill ",
                                    style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                  )
                                ],
                              ),
                              new Text(
                                widget.newLtrs,
                                style: new TextStyle(
                                    fontSize: 11.0,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await showDialog(
                                context: context,
                                builder: (_) => ImageDialog( img: widget.image,)
                            );
                          },

                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.network(
                              widget.image,
                              fit: BoxFit.contain,
                              height: 200.0,
                              width: 200.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ): new Offstage(),




              ],
            ),
          ),
        ],
      ),
    );
  }
}
