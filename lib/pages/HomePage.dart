import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fm_beta/CustomFontIcons.dart';
import 'package:fm_beta/bloc/BlocProvider.dart';
import 'package:fm_beta/pages/DirectoryViewPage.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:fm_beta/widgets/CategoryTile.dart';
import 'package:fm_beta/widgets/StorageMediaTile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fm_beta/model/StorageMedium.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final Function menuToggle;
  final int mtID;
  final AnimationController menuController;

  HomePage({
    Key key,
    this.userName,
    this.menuToggle,
    this.mtID,
    this.menuController
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tabCount = 1;
  FileUtils _fileUtils;
  Completer<bool> catCompleter;
  final Map<String, Category> categoryTitles = {
    'Documents' : Category.Document,
    'Pictures' : Category.Image,
    'Videos' : Category.Video,
    'Music' : Category.Music,
    'Archives' : Category.Archive,
    'Applications' : Category.Apk
  };
  final List<String> categoryAssets = <String>[
    'assets/icons/documents-folder.svg',
    'assets/icons/pictures-folder.svg',
    'assets/icons/video-folder.svg',
    'assets/icons/music-folder.svg',
    'assets/icons/archive-folder.svg',
    'assets/icons/apps-folder.svg'
  ];

  Future<void> _initFileUtil() async{
    _fileUtils = FileUtils();
    await _fileUtils.isolateReady;
  }

  @override
  void initState() {
    super.initState();
    _initFileUtil();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context).bloc;
    final mtBloc = BlocProvider.of(context).mtBloc;
    return LayoutBuilder(
      builder: (context, constraints){
        // final height = MediaQuery.of(context).size.height;
        // final width = MediaQuery.of(context).size.width;
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        bool isScaledDown = constraints.maxWidth <= (MediaQuery.of(context).size.width * 0.9);
        return Scaffold(
          backgroundColor: const Color(0xfff2f5f8),
          appBar: AppBar(
            backgroundColor: Color(0xff7579e7),
            leading: IconButton(
              highlightColor: Color(0xff7579e7),
              splashColor: Color(0xff7579e7),
              onPressed: widget.menuToggle,
              icon: Icon(CustomFontIcons.menu, color: Colors.white, size: 18,),
            ),
            actions: [
              GestureDetector(
                onTap: (){
                  HapticFeedback.vibrate();
                  mtBloc.toggleMTAnimation();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: isScaledDown ? height * 0.028 :  height * 0.022, horizontal: width * 0.02),
                  width: isScaledDown ? width * 0.07 :  width * 0.056,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Center(
                    child: Text('$tabCount', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Montserrat'),),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: width * 0.015, bottom: height * 0.006),
                child: IconButton(
                  highlightColor: Color(0xff7579e7),
                  splashColor: Color(0xff7579e7),
                  onPressed: (){},
                  icon: Icon(FontAwesomeIcons.search, color: Colors.white, size: isScaledDown ? 16 : 18,),
                ),
              )
            ],
            elevation: 0.0,
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                top: -(height * 0.13),
                left: -(width * 0.25),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: ClipOval(
                    child: Container(
                      height: height * 0.42,
                      width: width * 1.5,
                      color: Color(0xff7579e7),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.01,
                left: width * 0.08,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi, ${widget.userName}", style: TextStyle(fontSize: isScaledDown ? 22 :  28, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),),
                    Text("Let's organise stuff together", style: TextStyle(fontSize: isScaledDown ? 12 : 15, color: Colors.grey[300], fontFamily: 'Montserrat'),)
                  ],
                ),
              ),
              Positioned(
                top: height * 0.125,
                left: -(width * (width > 380 ? 0.1 : 0.08)),
                child: StreamBuilder<UnmodifiableListView<StorageMedium>>(
                  stream: bloc.storageMediaList,
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return Container(
                        // color: Colors.yellow,
                          width: width * 1.08,
                          height: height * 0.223,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              aspectRatio: 1.5,
                              viewportFraction:  width > 380 ? 0.65 : 0.7,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                            ),
                            items: snapshot.data.map((e) => StorageMediaTile(bloc: bloc, storageMedium: e, menuController: widget.menuController,)).toList(),
                          )
                      );
                    }else return Center(child: CircularProgressIndicator(),);
                  },
                ),
              ),
              Positioned(
                top: height * 0.365,
                left: width * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isScaledDown ? 19 : 22, fontFamily: 'Montserrat'),),
                  ],
                ),
              ),
              Positioned(
                top: height * 0.42,
                left: width * 0.08,
                child: Container(
                  height: height * 0.47,
                  width: width * 0.84,
                  // color: Colors.red,
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: (height * 0.015),
                        crossAxisSpacing: (width * 0.04),
                        childAspectRatio: height < 700 ? 1.2 : 1.1
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index){
                      return CategoryTile(
                        title: categoryTitles.keys.elementAt(index),
                        assetPath: categoryAssets[index],
                        contents: "75 Files, 6 Folders",
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}