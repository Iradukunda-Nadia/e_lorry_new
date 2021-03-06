import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter/scheduler.dart';

class pertPart extends StatefulWidget {
  @override
  _pertPartState createState() => _pertPartState();
}

class _pertPartState extends State<pertPart> {
  final _renderObjectKey = GlobalKey<ScaffoldState>();
  initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();
    truckNo = 'all';
    month = 'all';
    contString = '0';

  }

  var dateController = new TextEditingController();

  String userCompany;
  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
    });

  }

  String truckNo;
  String month;

  String filePath;

  String fileP;
  String Item;
  String isTruck;
  String isMonth;

  final formKey = GlobalKey<FormState>();
  final formK = GlobalKey<FormState>();

  Future<String> get _localP async {
    final directory = await getExternalStorageDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localF async {
    final path = await _localP;
    fileP = '/storage/emulated/0/Download/data.csv';
    return File('/storage/emulated/0/Download/PartRequests.csv').create();
  }
  getCsv() async {

    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

    List<List<dynamic>> rows = List<List<dynamic>>();


    rows.add(<String>['Truck', 'Item','Quantity', "Price", "reqDate", 'request by', 'Status'],);
    final QuerySnapshot result =
    truckNo == 'all' && month == 'all' ?
    await Firestore.instance.collection("partRequest").where('company', isEqualTo: userCompany).where('comment', isEqualTo: 'Approved').orderBy('timestamp', descending: true).getDocuments():
    truckNo != 'all' && month == 'all' ?
    await Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).where('Truck', isEqualTo: truckNo).orderBy('timestamp', descending: true).getDocuments():
    truckNo == 'all' && month != 'all' ?
    await Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).where('month', isEqualTo: month).orderBy('timestamp', descending: true).getDocuments():
    truckNo != 'all' && month != 'all' ?
    await Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).where('Truck', isEqualTo: truckNo).where('month', isEqualTo: month).orderBy('timestamp', descending: true).getDocuments():
    await Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents != null) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      documents.forEach((snapshot) {
        List<String> recind = <String>[
          snapshot.data['Truck'],
          snapshot.data['Item'],
          snapshot.data['Quantity'],
          snapshot.data['Price'],
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

  String _cont;
  int _contri;
  String contString;
  int total = 0;
  int newTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( newTotal != null ? 'Total spent: KSH.${contString}': 'waiting ...', style: TextStyle(fontSize: 10),),
        centerTitle: true,
        backgroundColor: const Color(0xff016836),
      ),

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
                  new Card (
                      child:
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: ListTile(
                              subtitle: Row(
                                children: <Widget>[
                                  Flexible(
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(5.0,5.0,5.0,5.0),
                                          child: RaisedButton(
                                            onPressed: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  // return object of type Dialog
                                                  return AlertDialog(
                                                    content: new Form(
                                                      key: formKey,
                                                      child: Center(
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
                                                                      onSaved: (val) => truckNo = val,

                                                                      onChanged: (value) {
                                                                        print(value);

                                                                        setState(() {
                                                                          Item = value;
                                                                          truckNo = value;
                                                                          Navigator.of(context).pop();
                                                                        });
                                                                      },
                                                                      hint: new Text("Select Vehicle"),
                                                                      style: TextStyle(color: Colors.black),

                                                                    );
                                                                  }
                                                              ),
                                                            ),

                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: new Text('OR'),
                                                            ),

                                                            Padding(
                                                              padding: const EdgeInsets.all(3.0),
                                                              child: FormBuilderChoiceChip(
                                                                spacing: 5.0,
                                                                runSpacing: 5.0,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                ),
                                                                attribute: truckNo,
                                                                options: [
                                                                  FormBuilderFieldOption(
                                                                    value: 'Yes',child: Text('Clear filter and show all trucks'),),
                                                                ],
                                                                onSaved: (val) => isTruck = val,
                                                                onChanged: (val){
                                                                  setState(() {
                                                                    isTruck = val;
                                                                    if (isTruck == 'Yes'){
                                                                      setState(() {
                                                                        truckNo = 'all';
                                                                      });
                                                                    }
                                                                    Navigator.of(context).pop();

                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text("Truck Filter",style: TextStyle(fontSize: 8)),
                                                Icon(Icons.filter_list)
                                              ],
                                            ),
                                          ),
                                        ),
                                      )),
                                  Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(5.0,5.0,5.0,5.0),
                                              child: RaisedButton(
                                                onPressed: (){
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      // return object of type Dialog
                                                      return AlertDialog(
                                                        content: new Form(
                                                          key: formK,
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                              ),
                                                              GestureDetector(
                                                                  onTap:() {
                                                                    showMonthPicker(
                                                                      context: context,
                                                                      firstDate: DateTime(2019),
                                                                      lastDate: DateTime(2030),
                                                                      initialDate: DateTime.now(),
                                                                    ).then((date) {
                                                                      if (date != null) {
                                                                        setState(() {
                                                                          dateController.text = DateFormat(' yyyy- MM').format(date);
                                                                          month = dateController.text;
                                                                        });
                                                                      }
                                                                    });
                                                                  },
                                                                  child:AbsorbPointer(
                                                                    child: TextFormField(
                                                                      onSaved: (val) {
                                                                        month = val;
                                                                      },
                                                                      onChanged: (val) {
                                                                        month = val;
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      controller: dateController,
                                                                      decoration: InputDecoration(
                                                                        labelText: "Select Month",
                                                                        icon: Icon(Icons.calendar_today),
                                                                      ),

                                                                    ),
                                                                  )
                                                              ),

                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: new Text('OR'),
                                                              ),

                                                              Padding(
                                                                padding: const EdgeInsets.all(3.0),
                                                                child: FormBuilderChoiceChip(

                                                                  spacing: 5.0,
                                                                  runSpacing: 5.0,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                  ),
                                                                  options: [
                                                                    FormBuilderFieldOption(
                                                                      value: 'Yes',child: Text('Clear Filter and show all Months'),),
                                                                  ],
                                                                  onSaved: (val) => isMonth = val,
                                                                  onChanged: (val){
                                                                    setState(() {
                                                                      isMonth = val;
                                                                      if (isMonth == 'Yes'){
                                                                        setState(() {
                                                                          month = 'all';
                                                                        });
                                                                      }
                                                                      Navigator.of(context).pop();
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                      );
                                                    },
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text("Month filter",style: TextStyle(fontSize: 8)),
                                                    Icon(Icons.filter_list)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                          //container
                                        ],
                                      )),
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),

                            ),
                          ),
                        ],
                      )),
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
                                  "Parts Request cost",
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
                          stream:
                          truckNo == 'all' && month == 'all' ?
                          Firestore.instance.collection("partRequest").where('company', isEqualTo: userCompany).where('comment', isEqualTo: 'Approved').orderBy('timestamp', descending: true).snapshots():
                          truckNo != 'all' && month == 'all' ?
                          Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).where('Truck', isEqualTo: truckNo).orderBy('timestamp', descending: true).snapshots():
                          truckNo == 'all' && month != 'all' ?
                          Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).where('month', isEqualTo: month).orderBy('timestamp', descending: true).snapshots():
                          truckNo != 'all' && month != 'all' ?
                          Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).where('Truck', isEqualTo: truckNo).where('month', isEqualTo: month).orderBy('timestamp', descending: true).snapshots():
                          Firestore.instance.collection("partRequest").where('comment', isEqualTo: 'Approved').where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return new Text('Loading...');
                            return new FittedBox(
                              child: DataTable(
                                columnSpacing: 8,
                                columns: <DataColumn>[
                                  new DataColumn(label: Text('DATE',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TRUCK',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('PART\nREQUESTED',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('QUANTITY',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
                                  new DataColumn(label: Text('TOTAL\n(KSH.)',style: new TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold),)),
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
    int tot = 0;
    snapshot.documents.forEach((document)
    {
      SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
        _cont = document["price"];
        _cont == null ? _contri =  int.parse('0') : _contri =  int.parse(_cont);
        newTotal = tot += _contri;
        contString = newTotal.toString();
      }));

    });

    List<DataRow> newList = snapshot.documents.map((doc) {
      return new DataRow(
          cells: [
            DataCell(Text(doc.data["date"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Truck"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Item"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["Quantity"],
              style: new TextStyle(fontSize: 8.0),)),
            DataCell(Text(doc.data["price"],
              style: new TextStyle(fontSize: 8.0),)),
          ]);}).toList();

    return newList;
  }

}