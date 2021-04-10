import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/BlocProvider.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/pages/FirstIntroPage.dart';
import 'package:fm_beta/pages/HomePage.dart';

class SplashScreen extends StatefulWidget {
  final FileSystemBloc bloc;

  SplashScreen({@required this.bloc});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData(){
    widget.bloc.exitSplashScreen.listen((exit) {
      if(exit){
        Navigator.push(context, FadeRoute(page: HomePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color.fromRGBO(0,1,25,1),
              child: Center(
                child: Image.asset('assets/icons/pfm_3x.png',
                  height: 180
                  , width: 155,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: height * 0.1,
              width: width,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              child: Center(
                child: Text('Phoenix File Manager', style: TextStyle(color: Colors.white, fontSize: 24),)
              ),
            ),
          )
        ],
      ),
    );
  }
}
