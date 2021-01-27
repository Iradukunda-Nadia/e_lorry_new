import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class General extends StatefulWidget {
  @override
  _GeneralState createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  final _renderObjectKey = GlobalKey<ScaffoldState>();
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

  String filePath;

  String fileP;

  Future<String> get _localP async {
    final directory = await getExternalStorageDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localF async {
    final path = await _localP;
    fileP = '/storage/emulated/0/Download/data.csv';
    return File('/storage/emulated/0/Download/${DateFormat('MMM yyyy').format(DateTime.now())}Service.csv').create();
  }
  getCsv() async {

    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

    List<List<dynamic>> rows = List<List<dynamic>>();


      rows.add(<String>['TRUCK', 'DATE', 'LITRES','REQUESTED FUEL','PER LTR', 'TOTAL (KSH.)', 'FUEL STATION', 'PAYMENT METHOD', 'RECEIPIENT', 'REQUESTED BY', 'STATUS', 'NEW READING'],);
      final QuerySnapshot result =
      await Firestore.instance.collection("fuelRequest").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
    if (documents != null) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      documents.forEach((snapshot) {
        List<String> recind = <String>[
          snapshot.data['Truck'],
          snapshot.data['date'],
          snapshot.data['Current litres'],
          snapshot.data['Requested fuel'],
          snapshot.data['Price per liter'],
          snapshot.data['Total'],
          snapshot.data['FuelStaion'],
          snapshot.data['payMethod'],
          snapshot.data['Receipent'],
          snapshot.data['reqby'],
          snapshot.data['status'],
          snapshot.data['New Fuel reading'],
        ];
        rows.add(recind);
      });

      await Permission.storage.request().isGranted;

      File f = await _localF;

      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("File downloaded Succefully"),
            content: new Text("It is located in the Download folder"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Row(children: [
          new Icon(Icons.file_download),
          SizedBox(width: 5.0,),
          new Text('Download Report')
        ],),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {
          getCsv();
        },
      ),
      body: new Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SingleChildScrollView(
            child: RepaintBoundary(
              key: _renderObjectKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new SizedBox(
                    height: 50.0,
                  ),
                  new Card(
                    child: new Container(
                      margin: new EdgeInsets.only(left: 5.0, right: 5.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Column(
                              children: <Widget>[
                                new Text(
                                  "Fuel requests as at: ${DateFormat(' dd MMM yyyy').format(DateTime.now())}",
                                  style: new TextStyle(
                                      fontSize: 12.0, fontWeight: FontWeight.w700),
                                ),



                              ],
                            ),
                          ),
                          new SizedBox(
                            height: 10.0,
                          ),

                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: Column(
                      mainAxisSize:MainAxisSize.min,
                      children: <Widget>[
                        new StreamBuilder(
                          stream: Firestore.instance.collection("fuelRequest").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return new Text('Loading...');
                            return new FittedBox(
                              child: DataTable(
                                columnSpacing: 8,
                                columns: <DataColumn>[
                                  new DataColumn(label: Text('DATE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TRUCK',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('LITRES',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('REQUESTED\nFUEL',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TOTAL\n(KSH.)',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('FUEL\nSTATION',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('PAYMENT\nMETHOD',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('STATUS',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('NEW\nREADING',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('REQUEST\nBY',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                ],
                                rows: _createRows(snapshot.data),

                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  )

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  List<DataRow> _createRows(QuerySnapshot snapshot) {

    List<DataRow> newList = snapshot.documents.map((doc) {
      return new DataRow(
          cells: [
            DataCell(Text(doc.data["date"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Truck"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Current litres"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Requested fuel"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Total"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["FuelStaion"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["payMethod"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["status"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["New Fuel reading"] != null ? doc.data["New Fuel reading"]: "",
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["reqby"],
              style: new TextStyle(fontSize: 8.0),)),
          ]);}).toList();

    return newList;
  }

}

class genFuel extends StatefulWidget {
  @override
  _genFuelState createState() => _genFuelState();
}

class _genFuelState extends State<genFuel> {
  final _renderObjectKey = GlobalKey<ScaffoldState>();
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

  String filePath;

  String fileP;

  Future<String> get _localP async {
    final directory = await getExternalStorageDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localF async {
    final path = await _localP;
    fileP = '/storage/emulated/0/Download/data.csv';
    return File('/storage/emulated/0/Download/${DateFormat('MMM yyyy').format(DateTime.now())}Fuel.csv').create();
  }
  getCsv() async {

    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

    List<List<dynamic>> rows = List<List<dynamic>>();


    rows.add(<String>['TRUCK', 'DATE', 'LITRES','REQUESTED FUEL','PER LTR', 'TOTAL (KSH.)', 'FUEL STATION', 'PAYMENT METHOD', 'RECEIPIENT', 'REQUESTED BY', 'STATUS', 'NEW READING'],);
    final QuerySnapshot result =
    await Firestore.instance.collection("fuelRequest").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents != null) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      documents.forEach((snapshot) {
        List<String> recind = <String>[
          snapshot.data['Truck'],
          snapshot.data['date'],
          snapshot.data['Current litres'],
          snapshot.data['Requested fuel'],
          snapshot.data['Price per liter'],
          snapshot.data['Total'],
          snapshot.data['FuelStaion'],
          snapshot.data['payMethod'],
          snapshot.data['Receipent'],
          snapshot.data['reqby'],
          snapshot.data['status'],
          snapshot.data['New Fuel reading'],
        ];
        rows.add(recind);
      });

      await Permission.storage.request().isGranted;

      File f = await _localF;

      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("File downloaded Succefully"),
            content: new Text("It is located in the Download folder"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Row(children: [
          new Icon(Icons.file_download),
          SizedBox(width: 5.0,),
          new Text('Download Report')
        ],),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {
          getCsv();
        },
      ),
      body: new Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SingleChildScrollView(
            child: RepaintBoundary(
              key: _renderObjectKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new SizedBox(
                    height: 50.0,
                  ),
                  new Card(
                    child: new Container(
                      margin: new EdgeInsets.only(left: 5.0, right: 5.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Column(
                              children: <Widget>[
                                new Text(
                                  "Materials Requested as at: ${DateFormat(' dd MMM yyyy').format(DateTime.now())}",
                                  style: new TextStyle(
                                      fontSize: 12.0, fontWeight: FontWeight.w700),
                                ),



                              ],
                            ),
                          ),
                          new SizedBox(
                            height: 10.0,
                          ),

                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: Column(
                      mainAxisSize:MainAxisSize.min,
                      children: <Widget>[
                        new StreamBuilder(
                          stream: Firestore.instance.collection("fuelRequest").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return new Text('Loading...');
                            return new FittedBox(
                              child: DataTable(
                                columnSpacing: 8,
                                columns: <DataColumn>[
                                  new DataColumn(label: Text('DATE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TRUCK',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('LITRES',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('REQUESTED\nFUEL',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TOTAL\n(KSH.)',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('FUEL\nSTATION',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('PAYMENT\nMETHOD',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('STATUS',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('NEW\nREADING',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('REQUEST\nBY',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                ],
                                rows: _createRows(snapshot.data),

                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  )

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  List<DataRow> _createRows(QuerySnapshot snapshot) {

    List<DataRow> newList = snapshot.documents.map((doc) {
      return new DataRow(
          cells: [
            DataCell(Text(doc.data["date"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Truck"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Current litres"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Requested fuel"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Total"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["FuelStaion"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["payMethod"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["status"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["New Fuel reading"] != null ? doc.data["New Fuel reading"]: "",
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["reqby"],
              style: new TextStyle(fontSize: 8.0),)),
          ]);}).toList();

    return newList;
  }

}

class genParts extends StatefulWidget {
  @override
  _genPartsState createState() => _genPartsState();
}

class _genPartsState extends State<genParts> {
  final _renderObjectKey = GlobalKey<ScaffoldState>();
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

  String filePath;

  String fileP;

  Future<String> get _localP async {
    final directory = await getExternalStorageDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localF async {
    final path = await _localP;
    fileP = '/storage/emulated/0/Download/data.csv';
    return File('/storage/emulated/0/Download/${DateFormat('MMM yyyy').format(DateTime.now())}PartsRequested.csv').create();
  }
  getCsv() async {

    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

    List<List<dynamic>> rows = List<List<dynamic>>();


    rows.add(<String>['Truck', 'Item','Quantity','Payment Type','Supplier 1', 'Price', 'VAT?' , "Supplier 2", "Price", 'VAT?', "Supplier 3", "Price", 'VAT?', "reqDate", 'request by', 'Status'],);
    final QuerySnapshot result =
    await Firestore.instance.collection("partRequest").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents != null) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      documents.forEach((snapshot) {
        List<String> recind = <String>[
          snapshot.data['Truck'],
          snapshot.data['Item'],
          snapshot.data['Quantity'],
          snapshot.data['paymentType'],
          snapshot.data['Supplier 1'],
          snapshot.data['quoteOne'],
          snapshot.data['1VAT'],
          snapshot.data['Supplier 2'],
          snapshot.data['quoteTwo'],
          snapshot.data['2VAT'],
          snapshot.data['Supplier 3'],
          snapshot.data['quoteThree'],
          snapshot.data['3VAT'],
          snapshot.data['reqDate'],
          snapshot.data['request by'],
          snapshot.data['status'],
        ];
        rows.add(recind);
      });

      await Permission.storage.request().isGranted;

      File f = await _localF;

      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("File downloaded Succefully"),
            content: new Text("It is located in the Download folder"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Row(children: [
          new Icon(Icons.file_download),
          SizedBox(width: 5.0,),
          new Text('Download Report')
        ],),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {
          getCsv();
        },
      ),
      body: new Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SingleChildScrollView(
            child: RepaintBoundary(
              key: _renderObjectKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new SizedBox(
                    height: 50.0,
                  ),
                  new Card(
                    child: new Container(
                      margin: new EdgeInsets.only(left: 5.0, right: 5.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Column(
                              children: <Widget>[
                                new Text(
                                  "Parts Requested as at: ${DateFormat(' dd MMM yyyy').format(DateTime.now())}",
                                  style: new TextStyle(
                                      fontSize: 12.0, fontWeight: FontWeight.w700),
                                ),



                              ],
                            ),
                          ),
                          new SizedBox(
                            height: 10.0,
                          ),

                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: Column(
                      mainAxisSize:MainAxisSize.min,
                      children: <Widget>[
                        new StreamBuilder(
                          stream: Firestore.instance.collection("partRequest").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return new Text('Loading...');
                            return new FittedBox(
                              child: DataTable(
                                columnSpacing: 8,
                                columns: <DataColumn>[
                                  new DataColumn(label: Text('DATE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TRUCK',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('ITEM',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('QUANTITY',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('PAYMENT\nMETHOD',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('CASH\nAMOUNT',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('SUPPLIER 1',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('SUPPLIER 1\n PRICE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('SUPPLIER 2',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('SUPPLIER 2\nPRICE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('SUPPLIER 3',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('SUPPLIER 3\nPRICE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('REQUEST\nBY',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),

                                ],
                                rows: _createRows(snapshot.data),

                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  )

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  List<DataRow> _createRows(QuerySnapshot snapshot) {

    List<DataRow> newList = snapshot.documents.map((doc) {
      return new DataRow(
          cells: [
            DataCell(Text(doc.data["reqDate"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["Truck"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["Item"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["Quantity"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["paymentType"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["amount"] != null ? doc.data["amount"]: "",
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["Supplier 1"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["quoteOne"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["Supplier 2"] ,
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["quoteTwo"] ,
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["Supplier 3"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["quoteThree"],
              style: new TextStyle(fontSize: 10.0),)),
            DataCell(Text(doc.data["request by"],
              style: new TextStyle(fontSize: 10.0),)),
          ]);}).toList();

    return newList;
  }

}



class genPOST extends StatefulWidget {
  @override
  _genPOSTState createState() => _genPOSTState();
}

class _genPOSTState extends State<genPOST> {
  final _renderObjectKey = GlobalKey<ScaffoldState>();
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

  String filePath;

  String fileP;

  Future<String> get _localP async {
    final directory = await getExternalStorageDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localF async {
    final path = await _localP;
    fileP = '/storage/emulated/0/Download/data.csv';
    return File('/storage/emulated/0/Download/${DateFormat('MMM yyyy').format(DateTime.now())}Service.csv').create();
  }
  getCsv() async {

    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

    List<List<dynamic>> rows = List<List<dynamic>>();


    rows.add(<String>['TRUCK', 'ENGINE','ELECTRONICS','BRAKES','FRONT SUSPENSION', 'REAR SUSPENSION', 'CABIN', 'BODY', 'TYRES', 'DATES', 'OTHER'],);
    final QuerySnapshot result =
    await Firestore.instance.collection("posttrip").where('company', isEqualTo: userCompany).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents != null) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      documents.forEach((snapshot) {
        List<String> recind = <String>[
          snapshot.data['Truck'],
          snapshot.data['Engine'].toString(),
          snapshot.data['Electronics'].toString(),
          snapshot.data['Brakes'].toString(),
          snapshot.data['Front suspension'].toString(),
          snapshot.data['Rear suspension'].toString(),
          snapshot.data['Cabin'].toString(),
          snapshot.data['Body'].toString(),
          snapshot.data['Wheel Details'].toString(),
          snapshot.data['Dates'].toString(),
          snapshot.data['Other'].toString(),
        ];
        rows.add(recind);
      });

      await Permission.storage.request().isGranted;

      File f = await _localF;

      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("File downloaded Succefully"),
            content: new Text("It is located in the Download folder"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Row(children: [
          new Icon(Icons.file_download),
          SizedBox(width: 5.0,),
          new Text('Download Report')
        ],),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {
          getCsv();
        },
      ),
      body: new Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SingleChildScrollView(
            child: RepaintBoundary(
              key: _renderObjectKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new SizedBox(
                    height: 50.0,
                  ),
                  new Card(
                    child: new Container(
                      margin: new EdgeInsets.only(left: 5.0, right: 5.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Column(
                              children: <Widget>[
                                new Text(
                                  "Parts Requested as at: ${DateFormat(' dd MMM yyyy').format(DateTime.now())}",
                                  style: new TextStyle(
                                      fontSize: 12.0, fontWeight: FontWeight.w700),
                                ),



                              ],
                            ),
                          ),
                          new SizedBox(
                            height: 10.0,
                          ),

                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: Column(
                      mainAxisSize:MainAxisSize.min,
                      children: <Widget>[
                        new StreamBuilder(
                          stream: Firestore.instance.collection("posttrip").where('company', isEqualTo: userCompany).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return new Text('Loading...');
                            return new FittedBox(
                              child: DataTable(
                                columnSpacing: 8,
                                columns: <DataColumn>[
                                  new DataColumn(label: Text('DATE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TRUCK',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('ENGINE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('ELECTRONICS',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('FRONT\n SUSPENSION',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('REAR\n SUSPENSION',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('CABIN',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('BODY',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TYRES',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('OTHER',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),

                                ],
                                rows: _createRows(snapshot.data),

                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  )

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  List<DataRow> _createRows(QuerySnapshot snapshot) {

    List<DataRow> newList = snapshot.documents.map((doc) {
      return new DataRow(
          cells: [
            DataCell(Text(doc.data["timestamp"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Truck"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Engine'].toString(),
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Electronics'].toString(),
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Brakes'].toString(),
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Rear suspension'].toString(),
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Cabin'].toString(),
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Body'].toString(),
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Wheel Details'].toString() ,
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data['Other'].toString() ,
              style: new TextStyle(fontSize: 8.0),)),


          ]);}).toList();

    return newList;
  }

}