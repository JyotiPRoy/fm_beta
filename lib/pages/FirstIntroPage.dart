import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fm_beta/pages/HomePage.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class FirstIntroPage extends StatefulWidget {
  @override
  _FirstIntroPageState createState() => _FirstIntroPageState();
}

class _FirstIntroPageState extends State<FirstIntroPage> {

//  Map initSortCriteria = <String, SortCriteria>{'Global' : SortCriteria.az};
  Map initSortCriteria = <String, String>{'Global' : SortCriteria.az.toString()};

  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  Widget build(BuildContext context) {
    /// We will beautify this page later
    return Scaffold(
      backgroundColor: Color.fromRGBO(0,1,25,1),
      body: Center(
        child: Text('Welcome to FM beta!', style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 28),),
      ),
    );
  }

  Future<void> initApp() async{
    PermissionStatus status = await Permission.storage.status;
    if(status.isUndetermined || status.isDenied){
      Permission.storage.request().then(
              (value){
            if(value.isDenied){
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Storage Permission denied'),
                      content: Text('Application will exit now. To grant permission start the app again.'
                          ' In case permission has been permanently denied unknowingly,'
                          ' visit the App info page to allow it.'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: (){
                            SystemNavigator.pop(animated: true);
                          },
                          child: Text('Ok'),
                        )
                      ],
                    );
                  }
              );
            } else if(value.isGranted){
              createSortCriteriaJsonFile();
              dispose();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          }
      );
    } else{
      dispose();
      Navigator.push(context, FadeRoute(page: HomePage()));
    }
  }

  Future<void> createSortCriteriaJsonFile() async{
    Directory path = await getApplicationDocumentsDirectory();
    File jsonFile = File('${path.path}/SortCriteriaPrefs.json');
    String jsonStr = jsonEncode(initSortCriteria);
    jsonFile.writeAsString(jsonStr);
    print('File created Successfully');
  }

}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        FadeTransition(
          opacity: animation,
          child: child,
        ),
  );
}
