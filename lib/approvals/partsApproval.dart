import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_lorry/manager/carService.dart';
import 'package:e_lorry/manager/report.dart';
import 'package:e_lorry/manager/reporting/Reports.dart';
import 'package:e_lorry/manager/reporting/report.dart';
import 'package:e_lorry/user/document.dart';
import 'package:e_lorry/user/post_trip.dart';
import 'package:e_lorry/user/truck_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_lorry/login.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';

import '../chat.dart';

import 'package:hover_ussd/hover_ussd.dart';
import 'package:android_intent/android_intent.dart';

final HoverUssd _hoverUssd = HoverUssd();

class partsApproval extends StatefulWidget {
  @override
  _partsApprovalState createState() => _partsApprovalState();
}

class _partsApprovalState extends State<partsApproval> {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parts Approval"),
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
  Firestore.instance.collection("partRequest");

  DocumentSnapshot _currentDocument;

  _updateData() async {
    await Firestore.instance
        .collection('request')
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
                child: Text("The are no pending requests"),);
            }
            else{
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data.documents[index];
                  return Card(
                    child: ListTile(
                      title: Text(doc.data["Item"], style: new TextStyle(color: Colors.black),),
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

                        Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new Approval(

                          itemID: doc.documentID,
                          itemName: doc.data["Item"],
                          itemQuantity: doc.data["Quantity"],
                          itemNumber: doc.data["Truck"],
                          reqName: doc.data["request by"],
                          reqDate: doc.data["date"],
                          brand1: doc.data["Supplier 1"],
                          reqOne: doc.data["quoteOne"],
                          vat1: doc.data["1VAT"],
                          brand2: doc.data["Supplier 2"],
                          reqTwo: doc.data["quoteTwo"],
                          vat2: doc.data["2VAT"],
                          brand3: doc.data["Supplier 3"],
                          reqThree: doc.data["quoteThree"],
                          vat3: doc.data["3VAT"],
                          reqBrand: doc.data["brand"],
                          reqPrice: doc.data["price"],
                          reqSupplier: doc.data["supplier"],
                          status: doc.data["status"],
                          reqComment: doc.data["comment"],
                          approvedQuote: doc.data["approvedQuote"],
                          approvedPrice: doc.data["price"],
                          payType: doc.data["paymentType"],
                          acc: doc.data['accNo'],
                          recepient: doc.data["Receipent"],
                          amount : doc.data['amount'],
                          payMethod: doc.data['payMethod'],
                          till: doc.data['Till'],
                          receivedBy: doc.data['Received by'],
                          img : doc.data['image'],


                        )));
                      },
                    ),
                  );

                },
              );

            }
          }),

    );

  }
}

class Approval extends StatefulWidget {

  String sample;
  String approvedQuote;
  String approvedPrice;
  String reqComment;
  String acc;
  String recepient;
  String amount;
  String receivedBy;
  String img;

  String itemID;
  String itemName;
  String itemQuantity;
  String itemNumber;
  String reqName;
  String reqDate;
  String reqOne;
  String reqTwo;
  String reqThree;
  String reqBrand;
  String reqPrice;
  String reqSupplier;
  String status;
  String brand1;
  String brand2;
  String brand3;
  String vat1;
  String vat2;
  String vat3;
  String payType;
  String payMethod;
  String till;


  Approval({
    this.vat1,
    this.vat2,
    this.vat3,
    this.approvedQuote,
    this.approvedPrice,
    this.reqComment,
    this.payType,
    this.acc,
    this.amount,
    this.recepient,
    this.payMethod,
    this.till,
    this.receivedBy,
    this.img,


    this.brand3,
    this.brand2,
    this.brand1,
    this.itemName,
    this.itemID,
    this.itemQuantity,
    this.itemNumber,
    this.reqName,
    this.reqDate,
    this.reqOne,
    this.reqTwo,
    this.reqThree,
    this.reqBrand,
    this.reqPrice,
    this.status,
    this.reqSupplier

  });

  @override
  _ApprovalState createState() => _ApprovalState();
}

class _ApprovalState extends State<Approval> {



  final formKey = GlobalKey<FormState>();
  final fKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _comment;
  String appQuote;
  String appPrice;
  String userCompany;

  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('user');
      userCompany = prefs.getString('company');
    });

  }

  void _approveCommand() {
    //get state of our Form
    final form = fKey.currentState;
    form.save();
    _updateStatus();
    _sendApproval();

  }

  void _approveandPay() {
    //get state of our Form
    _update();
    _show();

  }

  _update() async {
    await Firestore.instance
        .collection('partRequest')
        .document(widget.itemID)
        .updateData({
      'status': "Paid",
      'comment': "Paid",
      'approved by': currentUserEmail,
    });
  }

  String Pin;
  var pinCode = TextEditingController();

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
              },
            ),
          ],
        );
      },
    );
  }



  @override
  initState() {
    getStringValue();
    super.initState();
  }

  _updateStatus() async {
    if (radioItem =='1' ){
      setState(() {
        appQuote = widget.brand1;
        appPrice = widget.reqOne;
      });
    }
    if (radioItem =='2' ){
      setState(() {
        appQuote = widget.brand2;
        appPrice = widget.reqTwo;
      });
    }
    if (radioItem =='3' ){
      setState(() {
        appQuote = widget.brand3;
        appPrice = widget.reqThree;
      });
    }
    await Firestore.instance
        .collection('partRequest')
        .document(widget.itemID)
        .updateData({
      'status': "Approved",
      'comment': "Approved",
      'approved by': currentUserEmail,
      'approvedQuote': appQuote,
      'price': appPrice,

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

  var msg = TextEditingController();

  _updateData() async {
    await Firestore.instance
        .collection('requisition')
        .document(widget.itemID)
        .updateData({'status': "Manager Comment"});
  }

  _updateComment() async {
    await Firestore.instance
        .collection('requisition')
        .document(widget.itemID)
        .updateData({
      'comment': _comment,
    });
  }



  void _showRequest() {
    _updateData();
    // flutter defined function
    final form = formKey.currentState;
    form.reset();


  }
  String radioItem = '';

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
                            "${widget.payType} Purchase" ,
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
                                  "Item Requested",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.itemName,
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
                                  "Truck",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.itemNumber,
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
                                  "Requested by",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.reqName,
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
                                  "Request date",
                                  style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                )
                              ],
                            ),
                            new Text(
                              widget.reqDate,
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

                        widget.payType == 'Credit'? Column(
                          children: [
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
                                      "1st Quote",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.reqOne,
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
                                      "Supplier",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.brand1,
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
                                      "Including VAT?",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.vat1,
                                  style: new TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),
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
                                      "2nd Quote",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.reqTwo,
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
                                      "Supplier",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.brand2,
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
                                      "including VAT?",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.vat2,
                                  style: new TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Divider(),
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
                                      "3rd Quote",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.reqThree,
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
                                      "Supplier",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.brand3,
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
                                      "Including VAT?",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.vat3,
                                  style: new TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ):
                        Column (
                          children: [
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
                                  widget.amount,
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
                                      'Payment Method',
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.payMethod,
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
                                      "${widget.payMethod} no.",
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
                widget.payType == 'Credit'? Column(
                  children: [
                    widget.status != "Approved"?
                    new Card(
                      child: new Container(
                        margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new SizedBox(
                              height: 5.0,
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new SizedBox(
                                        width: 5.0,
                                      ),
                                      MaterialButton(
                                        onPressed: (){
                                          showDialog(
                                            context: context,
                                            builder:  (BuildContext context) {
                                              // return object of type Dialog
                                              return AlertDialog(
                                                content: Form(
                                                  key: formKey,
                                                  child: Column(
                                                    children: <Widget>[

                                                      new SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      new Text("Comment",
                                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),),

                                                      new SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                                        child: Container(
                                                          child: TextFormField(
                                                            keyboardType: TextInputType.multiline,
                                                            maxLines: null,
                                                            textCapitalization: TextCapitalization.sentences,
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontFamily: 'SFUIDisplay'
                                                            ),
                                                            decoration: InputDecoration(

                                                                errorStyle: TextStyle(color: Colors.red),
                                                                filled: true,
                                                                fillColor: Colors.white.withOpacity(0.1),
                                                                labelText: 'Comment',
                                                                labelStyle: TextStyle(
                                                                    fontSize: 11
                                                                )
                                                            ),
                                                            validator: (val) =>
                                                            val.isEmpty  ? 'Required' : null,
                                                            onSaved: (val) => _comment = val,
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  // usually buttons at the bottom of the dialog
                                                  new RaisedButton(
                                                    color: Colors.grey,
                                                    elevation: 16.0,
                                                    child: new Text("Comment"),
                                                    onPressed: () {
                                                      _submitCommand();
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text('Reject with Comment',
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
                                    ],
                                  ),
                                  MaterialButton(
                                    onPressed: (){
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                                return AlertDialog(
                                                  content: Form(
                                                    key: fKey,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Column(
                                                        children: [
                                                          RadioListTile(
                                                            groupValue: radioItem,
                                                            title: Text(widget.brand1),
                                                            subtitle: Text(widget.reqOne),
                                                            value: '1',
                                                            onChanged: (val) {
                                                              setState(() {
                                                                radioItem = val;
                                                              });
                                                            },
                                                          ),
                                                          RadioListTile(
                                                            groupValue: radioItem,
                                                            title: Text(widget.brand2),
                                                            subtitle: Text(widget.reqTwo),
                                                            value: '2',
                                                            onChanged: (val) {
                                                              setState(() {
                                                                radioItem = val;
                                                              });
                                                            },
                                                          ),

                                                          RadioListTile(
                                                            groupValue: radioItem,
                                                            title: Text(widget.brand3),
                                                            subtitle: Text(widget.reqThree),
                                                            value: '3',
                                                            onChanged: (val) {
                                                              setState(() {
                                                                radioItem = val;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    // usually buttons at the bottom of the dialog
                                                    new FlatButton(
                                                      child: new Text("Approve"),
                                                      onPressed: () {

                                                        _approveCommand();
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }
                                          );
                                        },
                                      );
                                    },
                                    child: Text('Approve Quote',
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
                                ],
                              ),
                            ),
                            new SizedBox(
                              height: 5.0,
                            ),

                          ],
                        ),
                      ),
                    ): new Offstage(),
                    new SizedBox(
                      height: 5.0,
                    ),
                    widget.status == "Manager Comment"?
                    new Card(
                      child: new Container(
                        margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new SizedBox(
                              height: 10.0,
                            ),
                            new Text("Comment", style: TextStyle(fontSize: 12 , color: Colors.grey),),
                            new SizedBox(
                              height: 10.0,
                            ),
                            new Text(widget.reqComment, style: TextStyle(fontSize: 15, color: Colors.grey)),

                            new SizedBox(
                              height: 10.0,
                            ),

                            MaterialButton(
                              child: Text('comment',
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
                              ), onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ): new Offstage(),

                    widget.status == "Received"?
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
                                        "Received by: ",
                                        style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                      )
                                    ],
                                  ),
                                  new Text(
                                    widget.receivedBy,
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
                                    builder: (_) => ImageDialog( img: widget.img,)
                                );
                              },

                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.network(
                                  widget.img,
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


                    widget.status == "Approved"?
                    new Card(
                      child: new Container(
                        margin: new EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new SizedBox(
                              height: 10.0,
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
                                      "Final Approved Brand",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.approvedQuote,
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
                                      "Final approved price",
                                      style: new TextStyle(color: Colors.black, fontSize: 18.0,),
                                    )
                                  ],
                                ),
                                new Text(
                                  widget.approvedPrice,
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

                          ],
                        ),
                      ),
                    ): new Offstage(),
                  ],
                ):
                Column(
                  children: [
                    new SizedBox(
                      height: 10.0,
                    ),
                    widget.status == "pending" && widget.payType == 'Cash'?
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
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                          child: MaterialButton(
                                            onPressed: (){
                                              if (widget.payMethod == 'Till') {
                                                _hoverUssd.sendUssd(
                                                  actionId :"0466d73d", extras: { 'tillNo': widget.till, "amount": ((int.parse(widget.amount)).round()).toString()});
                                              }
                                              if (widget.payMethod == 'Paybill') {
                                                _hoverUssd.sendUssd(
                                                  actionId :"ec8d62b1", extras: { 'businessNo': widget.till, "AcNumber": widget.acc, "amount": ((int.parse(widget.amount)).round()).toString()});
                                              }
                                              if (widget.payMethod == 'Phone') {
                                                _hoverUssd.sendUssd(
                                                  actionId :"8176f539", extras: { 'phoneNumber': widget.till, "amount": ((int.parse(widget.amount)).round()).toString()},  );
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

                            StreamBuilder(
                              stream: _hoverUssd.onTransactiontateChanged,
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.data == TransactionState.succesfull) {
                                  _approveandPay();
                                  return Text("succesfull");
                                } else if (snapshot.data == TransactionState.waiting) {
                                  return Text("pending");
                                } else if (snapshot.data == TransactionState.failed) {
                                  return Text("failed");
                                }
                                return Text("no transaction");
                              },
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
                                                'imageUrl': '',
                                                'senderName': currentUserEmail ,
                                                'senderPhotoUrl': '',
                                                'time': DateTime.now(),
                                                'company': userCompany,

                                              });
                                              _approveandPay();
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
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  String img;

  ImageDialog ({this.img});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          child: PhotoView(
            imageProvider: NetworkImage(img),
          )
      ),
    );
  }
}