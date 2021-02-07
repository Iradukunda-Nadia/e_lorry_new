import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

import '../../chat.dart';

class NightOut extends StatefulWidget {
  @override
  _NightOutState createState() => _NightOutState();
}

class _NightOutState extends State<NightOut> {
  initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();

  }

  String userCompany;
  String currentUser;
  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
      currentUser = prefs.getString('user');
    });
  }

  CollectionReference collectionReference =
  Firestore.instance.collection("NightOutRequest");

  DocumentSnapshot _currentDocument;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("Night-Out Requests"),
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
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.of(context).push(new CupertinoPageRoute(
                builder: (BuildContext context) => new noRequest()));
          },
          label: Text ("Request Night-Out")),

      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: collectionReference.where('company', isEqualTo: userCompany).where('reqby', isEqualTo: currentUser ).orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text("Waiting For Data..."),
                );
              } if ( snapshot.data == null ){
                print('no data');
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
                      Text("Looks like you haven't made any Requests Yet."),
                    ],
                  ),);

              }
              else{
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data.documents[index];
                    return Container(
                      decoration: doc.data['status'] == 'Approved' ? BoxDecoration(
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
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.data["Truck"],style: new TextStyle(color: Colors.black),),
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
                                        doc.data["date"],
                                        style: new TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  new Text(
                                    doc.data["time"],
                                    style: new TextStyle(

                                        color: Colors.indigo,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
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
                            Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new noDetail(

                              truck: doc.data["Truck"],
                              driver: doc.data["driver"],
                              number: doc.data["driverPhone"],
                              route: doc.data["route"],
                              drops: doc.data["drops"],
                              contract: doc.data["contract"],
                              travelR: doc.data["travelR"],
                              travelN: doc.data["travelN"],
                              travelT: doc.data["travelT"],
                              onoR: doc.data["onoR"],
                              onoN: doc.data["onoN"],
                              onoT: doc.data["onoT"],
                              emptyR: doc.data["emptyR"],
                              emptyN: doc.data["emptyN"],
                              emptyT: doc.data["emptyT"],
                              hireR: doc.data["hireR"],
                              hireN: doc.data["hireN"],
                              hireT: doc.data["hireT"],
                              boatR: doc.data["boatR"],
                              boatN: doc.data["boatN"],
                              boatT: doc.data["boatT"],
                              ferryR: doc.data["ferryR"],
                              ferryN: doc.data["ferryN"],
                              ferryT: doc.data["ferryT"],
                              offLoadR: doc.data["offLoadR"],
                              offLoadN: doc.data["offLoadN"],
                              offLoadT: doc.data["offLoadT"],
                              cessR: doc.data["cessR"],
                              cessN: doc.data["cessN"],
                              cessT: doc.data["cessT"],
                              fuelR: doc.data["fuelR"],
                              fuelN: doc.data["fuelN"],
                              fuelT: doc.data["fuelT"],

                              date: doc.data["date"],
                              status: doc.data["status"],
                              reqby: doc.data["reqby"],
                              docID: doc.documentID,
                              payMethod: doc.data['payMethod'],
                              company: doc.data['company'],
                              token: doc.data['token'],
                              total: doc.data['total'],


                            )));
                          },
                        ),
                      ),
                    );

                  },
                );

              }
            }),

      ),
    );
  }
}


class noRequest extends StatefulWidget {

  @override
  _noRequestState createState() => _noRequestState();
}

class _noRequestState extends State<noRequest> {
  final formKey = GlobalKey<FormState>();
  String Item;
  String contract;
  String driver;
  String number;
  String route;
  String drops;

  String travelR;
  String travelN;
  var travelT = new TextEditingController();


  String onoR;
  String onoN;
  var onoT= new TextEditingController();

  String emptyR;
  String emptyN;
  var emptyT= new TextEditingController();

  String hireR;
  String hireN;
  var hireT= new TextEditingController();

  String boatR;
  String boatN;
  var boatT= new TextEditingController();

  String ferryR;
  String ferryN;
  var ferryT= new TextEditingController();

  String offLoadR;
  String offLoadN;
  var offLoadT= new TextEditingController();

  String cessR;
  String cessN;
  var cessT= new TextEditingController();

  String fuelR;
  String fuelN;
  var fuelT= new TextEditingController();

  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();

      _loginCommand();
    }
  }
  final FirebaseMessaging _messaging = FirebaseMessaging();
  void _loginCommand() {
    final form = formKey.currentState;

    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection('NightOutRequest');
      String fcmToken = await _messaging.getToken();

      await reference.add({
        "Truck": Item,
        "driver": driver,
        "driverPhone": number,
        "route": route,
        "contract": contract,
        "drops": drops,

        "travelR": travelR,
        "travelN": travelN,
        "travelT": travelT.text,
        "onoR": onoR,
        "onoN": onoN,
        "onoT": onoT.text,
        'emptyR': emptyR,
        'emptyN': emptyN,
        'emptyT': emptyT.text,
        'hireR': hireR,
        'hireN': hireN,
        'hireT': hireT.text,
        'boatR': boatR,
        'boatN': boatN,
        'boatT': boatT.text,
        'ferryR': ferryR,
        'ferryN': ferryN,
        'ferryT': ferryT.text,
        'offLoadR': offLoadR,
        'offLoadN': offLoadN,
        'offLoadT': offLoadT.text,
        'cessR': cessR,
        'cessN': cessN,
        'cessT': cessT.text,
        'fuelR': fuelR,
        'fuelN': fuelN,
        'fuelT': fuelT.text,
        "date" : DateFormat(' yyyy- MM - dd').format(DateTime.now()),
        "month" : DateFormat(' yyyy- MM').format(DateTime.now()),
        'timestamp': DateTime.now(),
        "company": userCompany,
        'status': 'pending',
        'reqby':currentUser,
        'time': DateFormat('h:mm a').format(DateTime.now()),
        'token': fcmToken,
        'payMethod': 'phone',
        'total': (int.parse(travelT.text)+
                int.parse(onoT.text)+
                int.parse(emptyT.text)+
                int.parse(hireT.text)+
                int.parse(boatT.text)+
                int.parse(fuelT.text)+
                int.parse(offLoadT.text)+
                int.parse(cessT.text)+
                int.parse(fuelT.text)).toString(),
      });
    }).then((result) =>

        _showRequest());

  }

  void _showRequest() {
    // flutter defined function
    final form = formKey.currentState;
    form.reset();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text("Your request has been sent"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();
    travelR = '0';
    travelN ='0';

    onoR = '0';
    onoN ='0';


    emptyR = '0';
    emptyN ='0';

    hireR = '0';
    hireN ='0';

    boatR = '0';
    boatN ='0';

    ferryR = '0';
    ferryN ='0';

    offLoadR = '0';
    offLoadN ='0';

    cessR = '0';
    cessN ='0';

    fuelR = '0';
    fuelN ='0';


  }

  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
      currentUser = prefs.getString('user');
    });

  }

  String userCompany;
  String currentUser;


  @override
  Widget build(BuildContext context) {
    travelT.text = (int.parse(travelR)*int.parse(travelN)).toString();
    onoT.text = (int.parse(onoR)*int.parse(onoN)).toString();
    emptyT.text = (int.parse(emptyR)*int.parse(emptyN)).toString();
    hireT.text = (int.parse(hireR)*int.parse(hireN)).toString();
    boatT.text = (int.parse(boatR)*int.parse(boatN)).toString();
    ferryT.text = (int.parse(ferryR)*int.parse(ferryN)).toString();
    offLoadT.text = (int.parse(offLoadR)*int.parse(offLoadN)).toString();
    cessT.text = (int.parse(cessR)*int.parse(cessN)).toString();
    fuelT.text = (int.parse(fuelR)*int.parse(fuelN)).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('NIGHT-OUT REQUEST FORM'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
        key: formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
              ),
              SizedBox(
                height: 60.0,
                child:  new StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection("trucks").where('company', isEqualTo: userCompany).orderBy('plate').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return new Text("Please wait");
                      var length = snapshot.data.documents.length;
                      DocumentSnapshot ds = snapshot.data.documents[length - 1];
                      return new DropdownButtonFormField(
                        items: snapshot.data.documents.map((
                            DocumentSnapshot document) {
                          return DropdownMenuItem(
                              value: document.data["plate"],
                              child: new Text(document.data["plate"]));
                        }).toList(),
                        value: Item,
                        validator: (value) => value == null
                            ? 'Please Select a truck' : null,
                        onChanged: (value) {
                          print(value);

                          setState(() {
                            Item = value;
                          });
                        },
                        hint: new Text("Select Vehicle"),
                        style: TextStyle(color: Colors.black),

                      );
                    }
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Container(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'SFUIDisplay'
                    ),
                    decoration: InputDecoration(

                        errorStyle: TextStyle(color: Colors.red),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'Driver Name',
                        labelStyle: TextStyle(
                            fontSize: 11
                        )
                    ),
                    validator: (val) =>
                    val.isEmpty  ? 'Field cannot be empty' : null,
                    onSaved: (val) => driver = val,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Container(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'SFUIDisplay'
                    ),
                    decoration: InputDecoration(

                        errorStyle: TextStyle(color: Colors.red),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'Driver Number',
                        labelStyle: TextStyle(
                            fontSize: 11
                        )
                    ),
                    validator: (val) =>
                    val.isEmpty  ? 'Field cannot be empty' : null,
                    onSaved: (val) => number = val,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Container(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'SFUIDisplay'
                    ),
                    decoration: InputDecoration(

                        errorStyle: TextStyle(color: Colors.red),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'Contract (Specifics)',
                        labelStyle: TextStyle(
                            fontSize: 11
                        )
                    ),
                    validator: (val) =>
                    val.isEmpty  ? 'Field cannot be empty' : null,
                    onSaved: (val) => contract = val,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Container(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'SFUIDisplay'
                    ),
                    decoration: InputDecoration(

                        errorStyle: TextStyle(color: Colors.red),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'Route',
                        labelStyle: TextStyle(
                            fontSize: 11
                        )
                    ),
                    validator: (val) =>
                    val.isEmpty  ? 'Field cannot be empty' : null,
                    onSaved: (val) => route = val,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Container(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'SFUIDisplay'
                    ),
                    decoration: InputDecoration(

                        errorStyle: TextStyle(color: Colors.red),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'No Of Drops',
                        labelStyle: TextStyle(
                            fontSize: 11
                        )
                    ),
                    validator: (val) =>
                    val.isEmpty  ? 'Field cannot be empty' : null,
                    onSaved: (val) => drops = val,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Travel to: 1st drop without offloading 1/2 night-out', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => travelR = val,
                                    onChanged: (val){
                                      setState(() {
                                        travelR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          travelR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => travelN = val,
                                    onChanged: (val){
                                      setState(() {
                                        travelN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          travelN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: travelT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => travelT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        travelT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Offloading night-out full', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => onoR = val,
                                    onChanged: (val){
                                      setState(() {
                                        onoR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          onoR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => onoN = val,
                                    onChanged: (val){
                                      setState(() {
                                        onoN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          onoN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: onoT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => onoT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        onoT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Empty returns without offloading', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => emptyR = val,
                                    onChanged: (val){
                                      setState(() {
                                        emptyR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          emptyR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => emptyN = val,
                                    onChanged: (val){
                                      setState(() {
                                        emptyN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          emptyN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: emptyT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => emptyT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        emptyT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Provision for Sub hire', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => hireR = val,
                                    onChanged: (val){
                                      setState(() {
                                        hireR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          hireR = '0';
                                        });

                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => hireN = val,
                                    onChanged: (val){
                                      setState(() {
                                        hireN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          hireN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: hireT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => hireT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        hireT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Provision for Boat', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => boatR = val,
                                    onChanged: (val){
                                      setState(() {
                                        boatR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          boatR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => boatN = val,
                                    onChanged: (val){
                                      setState(() {
                                        boatN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          boatN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: boatT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => boatT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        boatT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Provision for Ferry', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => ferryR = val,
                                    onChanged: (val){
                                      setState(() {
                                        ferryR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          ferryR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      ),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => ferryN = val,
                                    onChanged: (val){
                                      setState(() {
                                        ferryN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          ferryN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      ),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: ferryT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => ferryT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        ferryT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Provision for off loaders', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => offLoadR = val,
                                    onChanged: (val){
                                      setState(() {
                                        offLoadR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          offLoadR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      ),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => offLoadN = val,
                                    onChanged: (val){
                                      setState(() {
                                        offLoadN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          offLoadN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      ),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: offLoadT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => offLoadT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        offLoadT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Provision for County Cess', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => cessR = val,
                                    onChanged: (val){
                                      setState(() {
                                        cessR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          cessR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      ),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => cessN = val,
                                    onChanged: (val){
                                      setState(() {
                                        cessN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          cessN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      ),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: cessT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => cessT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        cessT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  title: Text('Provision for Top-Up Fuel', style: TextStyle(
                      fontSize: 10
                  )),
                  subtitle: Row(
                    children: <Widget>[
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(

                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Rate',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => fuelR = val,
                                    onChanged: (val){
                                      setState(() {
                                        fuelR = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          fuelR = '0';
                                        });
                                      }
                                    },

                                  ),
                                ),
                              )
                              //container
                            ],
                          )
                      ),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'No. Of Night-Outs',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    onSaved: (val) => fuelN = val,
                                    onChanged: (val){
                                      setState(() {
                                        fuelN = val;
                                      });
                                      if (val == '' || val == null){
                                        setState(() {
                                          fuelN = '0';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          )),
                      Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0,0.0,5.0,5.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'SFUIDisplay'
                                    ),
                                    controller: fuelT,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        labelText: 'Total',
                                        labelStyle: TextStyle(
                                            fontSize: 8
                                        )
                                    ),
                                    validator: (val) =>
                                    val.isEmpty  ? 'Field cannot be empty' : null,
                                    onSaved: (val) => fuelT.text = val,
                                    onChanged: (val){
                                      setState(() {
                                        fuelT.text = val;
                                      });
                                    },
                                  ),
                                ),
                              )
                              //container
                            ],
                          ))
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),

                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ListTile(
                  leading: Text('Grand Total', style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold
                  )),
                  trailing: Text((
                      int.parse(travelT.text)+
                          int.parse(onoT.text)+
                          int.parse(emptyT.text)+
                          int.parse(hireT.text)+
                          int.parse(boatT.text)+
                          int.parse(ferryT.text)+
                          int.parse(offLoadT.text)+
                          int.parse(cessT.text)+
                          int.parse(fuelT.text)
                  ).toString(), style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold
                  )),

                ),
              ),
              Divider(),

              Padding(
                padding: EdgeInsets.fromLTRB(70, 10, 70, 0),
                child: MaterialButton(
                  onPressed: (){_submitCommand();},
                  child: Text('Submit',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'SFUIDisplay',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Colors.white,
                  elevation: 16.0,
                  minWidth: 400,
                  height: 50,
                  textColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                ),
              ),






            ],
          ),
          ),
        ),
      )
    );
  }
}

class noDetail extends StatefulWidget {
  String truck;
  String driver;
  String number;
  String route;
  String drops;
  String contract;
  String date;
  String company;
  String status;
  String reqby;
  String time;
  String token;
  String payMethod;
  String total;
  String docID;

  String travelR;
  String travelN;
  String travelT;


  String onoR;
  String onoN;
  String onoT;

  String emptyR;
  String emptyN;
  String emptyT;

  String hireR;
  String hireN;
  String hireT;

  String boatR;
  String boatN;
  String boatT;

  String ferryR;
  String ferryN;
  String ferryT;

  String offLoadR;
  String offLoadN;
  String offLoadT;

  String cessR;
  String cessN;
  String cessT;

  String fuelR;
  String fuelN;
  String fuelT;

  noDetail({
    this.truck,
    this.driver,
    this.number,
    this.route,
    this.drops,
    this.contract,
    this.date,
    this.company,
    this.status,
    this.reqby,
    this.time,
    this.token,
    this.payMethod,
    this.total,
    this.docID,

    this.travelR,
    this.travelN,
    this.travelT,


    this.onoR,
    this.onoN,
    this.onoT,

    this.emptyR,
    this.emptyN,
    this.emptyT,

    this.hireR,
    this.hireN,
    this.hireT,

    this.boatR,
    this.boatN,
    this.boatT,

    this.ferryR,
    this.ferryN,
    this.ferryT,

    this.offLoadR,
    this.offLoadN,
    this.offLoadT,

    this.cessR,
    this.cessN,
    this.cessT,

    this.fuelR,
    this.fuelN,
    this.fuelT,


  });

  @override
  _noDetailState createState() => _noDetailState();
}

class _noDetailState extends State<noDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text("Item Detail"),
        centerTitle: true,
      ),
      body:  new Stack(
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
                children: [
                  new SizedBox(
                    height: 20.0,
                  ),
                  new Card(
                    child: Container(
                      margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new SizedBox(
                              height: 10.0,
                            ),
                            ListTile(
                              title: Text (widget.contract),
                              subtitle: Text (widget.route),
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
                                      style: new TextStyle(color: Colors.black, fontSize: 12.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.truck,
                                  style: new TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),
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
                                      "Driver",
                                      style: new TextStyle(color: Colors.black, fontSize: 12.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.driver,
                                  style: new TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),
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
                                      "Phone",
                                      style: new TextStyle(color: Colors.black, fontSize: 12.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.number,
                                  style: new TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),

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
                                      "No. of Drops",
                                      style: new TextStyle(color: Colors.black, fontSize: 12.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.drops,
                                  style: new TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),

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
                                      style: new TextStyle(color: Colors.black, fontSize: 12.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.reqby,
                                  style: new TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),

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
                                      style: new TextStyle(color: Colors.black, fontSize: 12.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.date,
                                  style: new TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),
                            ListTile(
                              title: Text('Travel to: 1st drop without offloading 1/2 night-out', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                              subtitle: Text(widget.travelR , style: TextStyle(
                                                  fontSize: 10
                                              ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.travelN , style: TextStyle(fontSize: 10),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.travelT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Offloading night-out full', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(fontSize: 12),),
                                              subtitle: Text(widget.onoR , style: TextStyle(fontSize: 10),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.onoN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.onoT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Empty returns without offloading', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(fontSize: 12),),
                                              subtitle: Text(widget.emptyR , style: TextStyle(fontSize: 10),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.emptyN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.emptyT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Provision for Sub hire', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(fontSize: 12),),
                                              subtitle: Text(widget.hireR , style: TextStyle(fontSize: 10),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.hireN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.hireT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Provision for Boat', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.boatR , style: TextStyle(fontSize: 10),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.boatN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.boatT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Provision for Ferry', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                              subtitle: Text(widget.ferryR , style: TextStyle(
                                                  fontSize: 10
                                              ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.ferryN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.ferryT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Provision for off loaders', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                              subtitle: Text(widget.offLoadR , style: TextStyle(
                                                  fontSize: 10
                                              ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.offLoadN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.offLoadT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Provision for County Cess', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                              subtitle: Text(widget.cessR , style: TextStyle(
                                                  fontSize: 10
                                              ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.cessN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.cessT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            ListTile(
                              title: Text('Provision for Top-Up Fuel', style: TextStyle(
                                  fontSize: 10
                              )),
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Rate', style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                              subtitle: Text(widget.fuelR , style: TextStyle(
                                                  fontSize: 10
                                              ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('No. Of Night-Outs', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.fuelN , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: ListTile(
                                              title: Text('Total', style: TextStyle( fontSize: 12),),
                                              subtitle: Text(widget.fuelT , style: TextStyle(fontSize: 10 ),),
                                            ),
                                          )
                                          //container
                                        ],
                                      ))
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                            Divider(),

                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: ListTile(
                                leading: Text('Grand Total', style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold
                                )),
                                trailing: Text(widget.total, style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold
                                )),

                              ),
                            ),
                            Divider(),

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
                          ]
                      ),
                    ),
                  ),

                  new SizedBox(
                    height: 10.0,
                  ),


                ],
              ),

            )
          ]
      ),
    );
  }
}
