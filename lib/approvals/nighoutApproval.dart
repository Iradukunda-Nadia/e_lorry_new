import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../chat.dart';
import 'package:hover_ussd/hover_ussd.dart';
import 'package:flutter/cupertino.dart';
import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final HoverUssd _hoverUssd = HoverUssd();

class noApproval extends StatefulWidget {
  @override
  _noApprovalState createState() => _noApprovalState();
}

class _noApprovalState extends State<noApproval> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Night Out Requests"),
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
  Firestore.instance.collection("NightOutRequest");

  DocumentSnapshot _currentDocument;

  _updateData() async {
    await Firestore.instance
        .collection('NightOutRequest')
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

                          Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new AppNightOut(

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

    );

  }
}

class AppNightOut extends StatefulWidget {
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

  AppNightOut({
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
  _AppNightOutState createState() => _AppNightOutState();
}

class _AppNightOutState extends State<AppNightOut> {
  var msg = TextEditingController();

  void _approveCommand() {
    //get state of our Form
    _updateStatus();
    _show();

  }

  _updateStatus() async {
    await Firestore.instance
        .collection('NightOutRequest')
        .document(widget.docID)
        .updateData({
      'status': "Approved",
      'comment': "Approved",
      'approved by': currentUserEmail,
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
                margin: new EdgeInsets.only(left: 10, right: 10.0),
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
                                          _hoverUssd.sendUssd(
                                              actionId :"c482dc29", extras: { 'phoneNumber': widget.number, "amount": widget.total});
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
                                        'company': widget.company,
                                        'token': widget.token,
                                        'payment': 'Night-Out',

                                      });
                                      Firestore.instance.collection('combined')
                                          .add({
                                        'nightOut': widget.total,
                                        'company': widget.company,
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


          ],
        ),

      )
          ]
      ),
    );
  }
}
