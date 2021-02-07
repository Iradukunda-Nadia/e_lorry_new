import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:e_lorry/manager/cost/perFuel.dart';
import 'package:e_lorry/manager/cost/perNOut.dart';
import 'package:e_lorry/manager/cost/perPart.dart';
import 'package:e_lorry/manager/cost/perCombined.dart';


class perTabs extends StatefulWidget {
  @override
  _perTabsState createState() => _perTabsState();
}

class _perTabsState extends State<perTabs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff016836),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new CircleAvatar(
              backgroundColor: Colors.white,
              radius: 60.0,
              child: new Icon(Icons.assignment,
                color: const Color(0xff016836),
                size: 50.0,
              ),
            ),
            new SizedBox(
              height: 10.0,
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
              child: new InkWell(
                onTap: () {
                  Navigator.of(context).push(new CupertinoPageRoute(
                      builder: (BuildContext context) => new perFuel()
                  ));
                },
                child: new Container(
                  height: 60.0,
                  margin: new EdgeInsets.only(top: 5.0),
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new Container(
                      margin: new EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 2.0),
                      height: 60.0,
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(20.0))),
                      child: new Center(
                          child: new Text(
                            "Fuel request Cost Report",
                            style: new TextStyle(
                                color: const Color(0xff016836), fontSize: 20.0),
                          )),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
              child: new InkWell(
                onTap: () {
                  Navigator.of(context).push(new CupertinoPageRoute(
                      builder: (BuildContext context) => new pertPart()
                  ));
                },
                child: new Container(
                  height: 60.0,
                  margin: new EdgeInsets.only(top: 5.0),
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new Container(
                      margin: new EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 2.0),
                      height: 60.0,
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(20.0))),
                      child: new Center(
                          child: new Text(
                            "Part Request Cost Report",
                            style: new TextStyle(
                                color: const Color(0xff016836), fontSize: 20.0),
                          )),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
              child: new InkWell(
                onTap: () {
                  Navigator.of(context).push(new CupertinoPageRoute(
                      builder: (BuildContext context) => new perNOut()
                  ));
                },
                child: new Container(
                  height: 60.0,
                  margin: new EdgeInsets.only(top: 5.0),
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new Container(
                      margin: new EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 2.0),
                      height: 60.0,
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(20.0))),
                      child: new Center(
                          child: new Text(
                            "Night-Out Request Cost Report",
                            style: new TextStyle(
                                color: const Color(0xff016836), fontSize: 20.0),
                          )),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
              child: new InkWell(
                onTap: () {
                  Navigator.of(context).push(new CupertinoPageRoute(
                    builder: (BuildContext context) => new perCombined()
                ));
                  },
                child: new Container(
                  height: 60.0,
                  margin: new EdgeInsets.only(top: 5.0),
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new Container(
                      margin: new EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 2.0),
                      height: 60.0,
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(20.0))),
                      child: new Center(
                          child: new Text(
                            "All",
                            style: new TextStyle(
                                color: const Color(0xff016836), fontSize: 20.0),
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

