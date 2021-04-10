import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fm_beta/bloc/BlocProvider.dart';
import 'package:fm_beta/bloc/MTHelperBloc.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/pages/FirstIntroPage.dart';
import 'package:fm_beta/pages/HomePage.dart';
import 'package:fm_beta/pages/HomeStack.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      bloc: FileSystemBloc(),
      mtBloc: MTHelperBloc(),
      child: FMBetaMain(),
    ),
  );
}

class FMBetaMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mtBloc = BlocProvider.of(context).mtBloc;
    FlutterStatusbarcolor.setStatusBarColor(Colors.white.withOpacity(0));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: checkFirstRun(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return FirstIntroPage();
            } else
              return HomeStack(
                mtBloc: mtBloc,
              );
          } else
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        },
      ),
    );
  }

  Future<bool> checkFirstRun() async {
    FileSystemEntity dataPath = await getApplicationDocumentsDirectory();
    if (await File('${dataPath.path}/SortCriteriaPrefs.json').exists()) {
      return false;
    } else
      return true;
  }
}
