import 'package:e_lorry/admin/adminHome.dart';
import 'package:e_lorry/approvals/appTabs.dart';
import 'package:e_lorry/manager/dailyReport.dart';
import 'package:e_lorry/manager/reporting/genReport.dart';
import 'package:e_lorry/signup.dart';
import 'package:e_lorry/user/fuelRequest.dart';
import 'package:e_lorry/user/partRequest.dart';
import 'package:e_lorry/user/requisition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'manager/reporting/pdfView.dart';
import 'mechanic/car.dart';
import 'mechanic/vehicle.dart';
import 'user/user.dart';
import 'admin/Admin.dart';
import 'manager/manager.dart';
import 'mechanic/mech.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:overlay_support/overlay_support.dart';
import 'testPay.dart';
import 'manager/cost/perFuel.dart';

const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.nadia.e_lorry';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  List<Color> _backgroundColor;
  Color _iconColor;
  Color _textColor;
  List<Color> _actionContainerColor;
  Color _borderContainer;
  bool colorSwitched = false;
  var logoImage;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  //We have two private fields here
  String _email;
  String _uid;
  String _password;
  String name1;
  String pw1;
  String name2;
  String pw2;
  String name3;
  String pw3;
  String name4;
  String pw4;
  String avatar;
  String id;
  String user;
  String status;
  bool checkedValue;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => _launchURL(PLAY_STORE_URL),
            ),
            FlatButton(
              child: Text(btnLabelCancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }







  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;

    //`validate()` validates every FormField that is a descendant of this Form,
    // and returns true if there are no errors.
    if (form.validate()) {
      //`save()` Saves every FormField that is a descendant of this Form.
      form.save();

      // Email & password matched our validation rules
      // and are saved to _email and _password fields.
      _loginCommand();
    }
  }




  _loginCommand() async {
    var collectionReference = Firestore.instance.collection('userID');
    var query = collectionReference.where("uid", isEqualTo: _email ).where('pw', isEqualTo: _password);
    query.getDocuments().then((querySnapshot) {
      if (querySnapshot.documents.length == 0) {
        final snack = SnackBar(
          content: Text('invallid login details'),
        );
        scaffoldKey.currentState.showSnackBar(snack);
      } else {
        querySnapshot.documents.forEach((document)
        async {

          var newQuery = Firestore.instance.collection('companies').where("company", isEqualTo: document['company'] );
          newQuery.getDocuments().then((querySnapshot) {
            if (querySnapshot.documents.length != 0) {
              querySnapshot.documents.forEach((doc)
              async {
                setState(() {
                  status = doc['status'];


                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('compLogo', doc['logo']);
                prefs.setString('compEmail', doc['email']);
                prefs.setString('compPhone', doc['phone']);
                prefs.setString('compName', doc['name']);


                if( status != "Active" ) {
                  showDialog(
                      context: context, // user must tap button!
                      builder: (BuildContext context) {
                        return WillPopScope(
                          onWillPop: () async =>false,
                          child: CupertinoAlertDialog(
                            title: new Icon(Icons.error_outline, size: 50,),
                            content: Text('Unfortunately Your account Status is currently Suspended \n Contact the system admin for more information.'),
                            actions: <Widget>[
                              CupertinoButton(
                                child: Text("Okay"),
                                onPressed: () async{
                                  SystemNavigator.pop();
                                },
                              )
                            ],
                          ),
                        );
                      }
                  );
                }

              });

            }
          });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('user', document['name']);
            prefs.setString('company', document['company']);
            prefs.setString('ref', document['ref']);
            setState(() {
              id = document['dept'];

            });

          if (checkedValue = true){

            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('userID', _email);
            prefs.setString('LoggedIn', 'yes');
          }


            if( id == "Fleet Manager" ) {
              _messaging.subscribeToTopic('manager${document['company']}');
              _messaging.subscribeToTopic('all${document['company']}');
              Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                  builder: (BuildContext context) => new dailyRep()
              ));
            }
            if(id == "Accounts" ) {
              _messaging.subscribeToTopic('puppies${document['company']}');
              _messaging.subscribeToTopic('all${document['company']}');
              Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                  builder: (BuildContext context) => new Requisition()
              ));

            }

            if(id == "Chief Mechanic" ) {
              _messaging.subscribeToTopic('mech${document['company']}');
              _messaging.subscribeToTopic('all${document['company']}');
              Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                  builder: (BuildContext context) => new vehicleService()
              ));

            }
            if(id == "Administrator") {
              _messaging.subscribeToTopic('admin${document['company']}');
              _messaging.subscribeToTopic('all${document['company']}');
              Navigator.of(context).push(new CupertinoPageRoute(
                  builder: (BuildContext context) => new adminHome()
              ));

            }
          if(id == "Approvals" ) {
            _messaging.subscribeToTopic('approvals${document['company']}');
            _messaging.subscribeToTopic('all${document['company']}');
            Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                builder: (BuildContext context) => new Approvals()
            ));

          }



        });
      }
    });
  }

  void changeTheme() async {
    if (colorSwitched) {
      setState(() {
        logoImage = 'assets/wallet.png';
        _backgroundColor = [
          Color.fromRGBO(252, 214, 0, 1),
          Color.fromRGBO(251, 207, 6, 1),
          Color.fromRGBO(250, 197, 16, 1),
          Color.fromRGBO(249, 161, 28, 1),
        ];
        _iconColor = Colors.white;
        _textColor = Color.fromRGBO(253, 211, 4, 1);
        _borderContainer = Color.fromRGBO(34, 58, 90, 0.2);
        _actionContainerColor = [
          Color.fromRGBO(47, 75, 110, 1),
          Color.fromRGBO(43, 71, 105, 1),
          Color.fromRGBO(39, 64, 97, 1),
          Color.fromRGBO(34, 58, 90, 1),
        ];
      });
    } else {
      setState(() {
        logoImage = 'assets/images/wallet_logo.png';
        _borderContainer = Color.fromRGBO(252, 233, 187, 1);
        _backgroundColor = [
          Color.fromRGBO(249, 249, 249, 1),
          Color.fromRGBO(241, 241, 241, 1),
          Color.fromRGBO(233, 233, 233, 1),
          Color.fromRGBO(222, 222, 222, 1),
        ];
        _iconColor = Colors.black;
        _textColor = Colors.black;
        _actionContainerColor = [
          Color.fromRGBO(255, 212, 61, 1),
          Color.fromRGBO(255, 212, 55, 1),
          Color.fromRGBO(255, 211, 48, 1),
          Color.fromRGBO(255, 211, 43, 1),
        ];
      });
    }
  }
  @override
  void initState() {
    checkedValue = false;
    changeTheme();
    super.initState();
    _messaging.getToken().then((token) {
      print(token);
    });
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showOverlayNotification((context) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading: SizedBox.fromSize(
                    size: const Size(40, 40),
                    child: ClipOval(
                        child: Container(
                          child: Image.asset(
                            logoImage,
                            fit: BoxFit.contain,
                          ),
                        ))),
                title: Text(message['notification']['title']),
                subtitle: Text(message['notification']['body']),
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context).dismiss();
                    }),
              ),
            ),
          );
        }, duration: Duration(milliseconds: 7000));

        print(message['notification']['title']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );


    setState(() {
      logoImage = 'assets/log02.png';
      _borderContainer = Color.fromRGBO(252, 233, 187, 1);
      _backgroundColor = [
        Color.fromRGBO(255, 180, 0, 1),
        Color.fromRGBO(255, 201, 0, 1),
        Color.fromRGBO(255, 206, 26, 1),
        Color.fromRGBO(255, 215, 118, 1),
      ];
      _iconColor = Colors.white;
      _textColor = Colors.white;
      _actionContainerColor = [
        Color.fromRGBO(199, 21, 21, 1),
        Color.fromRGBO(239, 36, 36, 1),
        Color.fromRGBO(247, 60, 60, 1),
        Color.fromRGBO(255, 36, 36, 1),
      ];
    });
  }

  final FirebaseMessaging _messaging = FirebaseMessaging();


  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: SafeArea(
          child: GestureDetector(
            onLongPress: () {},
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Image.asset(
                      logoImage,
                      fit: BoxFit.contain,
                      height: 130.0,
                      width: 330.0,
                    ),
                  ),

                  Column(
                    children: <Widget>[
                      Container(
                        height: 450.0,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),

                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10,10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15)),
                              color: const Color(0xff016836),

                                ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                                    child: Container(
                                      child: Text("Welcome", style: TextStyle(color: Colors.white, fontSize: 18),)
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                                    child: Container(
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'SFUIDisplay'
                                        ),
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(color: Colors.white),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.1),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: new BorderSide(color: Colors.white70),
                                            ),
                                            labelText: 'UserID',
                                            prefixIcon: Icon(Icons.person_outline),
                                            labelStyle: TextStyle(
                                                fontSize: 15
                                            )
                                        ),
                                        textCapitalization: TextCapitalization.sentences,
                                        validator: (val) =>
                                        val.isEmpty  ? 'Enter a valid Username' : null,
                                        onSaved: (val) => _email = val,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                                    child: Container(
                                      child: TextFormField(
                                        obscureText: true,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'SFUIDisplay'
                                        ),
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(color: Colors.white),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.1),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: new BorderSide(color: Colors.white70),
                                            ),
                                            labelText: 'Password',
                                            prefixIcon: Icon(Icons.lock_outline),
                                            labelStyle: TextStyle(
                                                fontSize: 15
                                            )
                                        ),
                                        validator: (val) =>
                                        val.length < 4 ? 'Your password is too Password too short..' : null,
                                        onSaved: (val) => _password = val,
                                      ),
                                    ),
                                  ),
                                  CheckboxListTile(
                                    title: Text("Remember me"),
                                    value: checkedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValue = newValue;
                                      });

                                    },
                                    controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(70, 10, 70, 0),
                                    child: MaterialButton(
                                      onPressed: _submitCommand,
                                      child: Text('SIGN IN',
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FlatButton(
                                        child: new Text(
                                            "New user? Sign up here",
                                            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Colors.white60)),
                                        onPressed: (){
                                          Navigator.of(context).push(new MaterialPageRoute(
                                            builder: (BuildContext context) => new Signup()
                                        ));
                                        }
                                     ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Logged extends StatefulWidget {
  String userID;

  Logged({

    this.userID,
  });

  @override
  _LoggedState createState() => _LoggedState();
}

class _LoggedState extends State<Logged> {
  bool colorSwitched = false;
  var logoImage;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  //We have two private fields here
  String _email;
  String _uid;
  String _password;
  String name1;
  String pw1;
  String name2;
  String pw2;
  String name3;
  String pw3;
  String name4;
  String pw4;
  String avatar;
  String id;
  String user;
  String status;
  bool checkedValue = false;



  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;

    //`validate()` validates every FormField that is a descendant of this Form,
    // and returns true if there are no errors.
    if (form.validate()) {
      //`save()` Saves every FormField that is a descendant of this Form.
      form.save();

      // Email & password matched our validation rules
      // and are saved to _email and _password fields.
      _loginCommand();
    }
  }




  _loginCommand() async {
    var collectionReference = Firestore.instance.collection('userID');
    var query = collectionReference.where("uid", isEqualTo: email ).where('pw', isEqualTo: _password);
    query.getDocuments().then((querySnapshot) {
      if (querySnapshot.documents.length == 0) {
        final snack = SnackBar(
          content: Text('invallid login details'),
        );
        scaffoldKey.currentState.showSnackBar(snack);
      } else {
        querySnapshot.documents.forEach((document)
        async {

          var newQuery = Firestore.instance.collection('companies').where("company", isEqualTo: document['company'] );
          newQuery.getDocuments().then((querySnapshot) {
            if (querySnapshot.documents.length != 0) {
              querySnapshot.documents.forEach((doc)
              async {
                setState(() {
                  status = doc['status'];


                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('compLogo', doc['logo']);
                prefs.setString('compEmail', doc['email']);
                prefs.setString('compPhone', doc['phone']);
                prefs.setString('compName', doc['name']);


                if( status != "Active" ) {
                  showDialog(
                      context: context, // user must tap button!
                      builder: (BuildContext context) {
                        return WillPopScope(
                          onWillPop: () async =>false,
                          child: CupertinoAlertDialog(
                            title: new Icon(Icons.error_outline, size: 50,),
                            content: Text('Unfortunately Your account Status is currently Suspended \n Contact the system admin for more information.'),
                            actions: <Widget>[
                              CupertinoButton(
                                child: Text("Okay"),
                                onPressed: () async{
                                  SystemNavigator.pop();
                                },
                              )
                            ],
                          ),
                        );
                      }
                  );
                }

              });

            }
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user', document['name']);
          prefs.setString('company', document['company']);
          prefs.setString('ref', document['ref']);
          setState(() {
            id = document['dept'];

          });


          if( id == "Fleet Manager" ) {
            Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                builder: (BuildContext context) => new dailyRep()
            ));
          }
          if(id == "Accounts" ) {
            Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                builder: (BuildContext context) => new Requisition( use: 'mech',)
            ));

          }

          if(id == "Chief Mechanic" ) {
            Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                builder: (BuildContext context) => new vehicleService()
            ));

          }

          if(id == "Administrator") {
            Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                builder: (BuildContext context) => new adminHome()
            ));

          }
          if(id == "Approvals" ) {
            _messaging.subscribeToTopic('approvals${document['company']}');
            _messaging.subscribeToTopic('all${document['company']}');
            Navigator.of(context).pushReplacement(new CupertinoPageRoute(
                builder: (BuildContext context) => new Approvals()
            ));

          }
        });
      }
    });
  }


  String email;
  checkLoggedin() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('userID');


  }
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => _launchURL(PLAY_STORE_URL),
            ),
            FlatButton(
              child: Text(btnLabelCancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    checkLoggedin();
    super.initState();


    setState(() {
      logoImage = 'assets/log02.png';
    });
  }

  final FirebaseMessaging _messaging = FirebaseMessaging();


  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff016836),
      key: scaffoldKey,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0,55.0, 25.0, 8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                  width: 140.0,
                  height: 100.0,
                  decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image:  AssetImage('assets/log02.png')
                      )
                  )
              ),
            ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: GestureDetector(
                onLongPress: () {},
                child: Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  decoration: BoxDecoration(
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),

                      ),

                      Expanded(
                        child: ClipPath(
                          clipper: MyClipper(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(30, 200, 20, 5),
                                      child: Container(
                                          child:Text(widget.userID,textAlign: TextAlign.center, style: TextStyle(color: const Color(0xff016836), fontSize: 18, ),)
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(30, 40, 5, 20),
                                      child: Container(
                                          child: Text("Welcome Back", style: TextStyle(color: const Color(0xff016836), fontSize: 30, fontWeight: FontWeight.bold, ),)
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                                      child: Container(
                                        child: TextFormField(
                                          obscureText: true,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'SFUIDisplay'
                                          ),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(color: const Color(0xff016836)),
                                              filled: true,
                                              fillColor: Colors.white.withOpacity(0.1),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: new BorderSide(color: Colors.white70),
                                              ),
                                              labelText: 'Enter Password',
                                              prefixIcon: Icon(Icons.lock_outline),
                                              labelStyle: TextStyle(
                                                  fontSize: 15
                                              )
                                          ),
                                          validator: (val) =>
                                          val.length < 4 ? 'Your password is too Password too short..' : null,
                                          onSaved: (val) => _password = val,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(20, 10, 150, 0),
                                      child: MaterialButton(
                                        onPressed: _submitCommand,
                                        child: Text('SIGN IN',
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FlatButton(
                                          child: new Text(
                                              "Would you like to Logout?",
                                              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Colors.grey)),
                                          onPressed: () async {
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            prefs.remove('email');
                                            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                                                builder: (BuildContext context) => new LoginScreen()
                                            ));
                                          }
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height/2);


    path.quadraticBezierTo(

        size.width * 1/3, 0.0, 0.0, size.height /3);



    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}