import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fm_beta/bloc/SelectionBloc.dart';
import 'package:fm_beta/model/StorageMedium.dart';
import 'package:fm_beta/utils/ThumbnailProvider.dart';
import 'package:fm_beta/widgets/AnimatedBottomBar.dart';
import 'package:fm_beta/widgets/GridTileView.dart';
import 'package:fm_beta/widgets/PathNavigator.dart';
import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';

enum SelectionMode{
  ON,
  OFF,
  isCopying
}

class DirectoryViewPage extends StatefulWidget {
  final FileSystemBloc bloc;
  final StorageMedium parentMedium;
  final Key mtID;

  DirectoryViewPage({
    @required this.bloc,
    @required this.parentMedium,
    @required this.mtID
  });

  @override
  _DirectoryViewPageState createState() => _DirectoryViewPageState();
}

class _DirectoryViewPageState extends State<DirectoryViewPage> with TickerProviderStateMixin{
  FileSystemBloc bloc;
//  SelectionBloc selectionBloc;
  ThumbnailProvider thumbnailProvider;
  Directory tempDir;
  String currentPath;
  List<Uint8List> videoThumbnails;
  PathNavigator pathNavigator;
  Map<Key,FileSystemEntity> _selectedItems = Map<Key,FileSystemEntity>();
  StreamController<SelectionMode> selectionModeController = StreamController<SelectionMode>.broadcast();
  SelectionMode selectionMode = SelectionMode.OFF;
  AnimationController controller1, controller2;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    bloc = widget.bloc;
    bloc.folderPath.add(widget.parentMedium.path);
    currentPath = widget.parentMedium.path;
    bloc.currentPath.listen((path){
      if(this.mounted){
        setState(() {
          currentPath = path;
        });
      }
    });
    selectionModeController.stream.listen((mode){
      if(this.mounted){
        setState(() {
          selectionMode = mode;
        });
      }
    });
    controller1 = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    controller2 = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this
    );
    pathNavigator = PathNavigator(initPath: widget.parentMedium.path, bloc: bloc,);
    videoThumbnails = <Uint8List>[];
    initThumbnails();
  }

  Sink<SelectionMode> get selectionModeSetter => selectionModeController.sink;

  @override
  void dispose(){
    // thumbnailProvider.dispose(); TODO: Needs A Rework!!
    dev.log('DIRECTORYPAGE WAS DISPOSED!');
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  Future<void> initThumbnails() async{
    thumbnailProvider = ThumbnailProvider();
    thumbnailProvider.setScrollController(_scrollController);
    // await thumbnailProvider.isolateReady;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xff7579e7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff7579e7),
        leading: Icon(CupertinoIcons.back, color: Colors.white,),
        title: Text('${widget.parentMedium.name}', style: TextStyle(color: Colors.white, fontSize: 20), overflow: TextOverflow.ellipsis,),
        actions: <Widget>[
          InkWell(
            onTap: (){

            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: height > 700 ? height * 0.02 : height * 0.015),
              padding: EdgeInsets.symmetric(horizontal: width * 0.012),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Center(
                child: Icon(Icons.home, color: Colors.white, size: 12,),
              ),
            ),
          ),
          SizedBox(width: width * 0.012,),
          IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: (){

          },),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
                height: height * 0.06,
                width: width,
                child: pathNavigator,
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Expanded(
                child: WillPopScope(
                  onWillPop: () async{
                    if(selectionMode == SelectionMode.ON){
                      if(controller2.isCompleted){
                        await controller2.reverse();
                      }else{
                        if(controller1.isCompleted){
                          ///TODO: making moreTapped = false
                          controller1.reverse();
                        }
                        selectionModeSetter.add(SelectionMode.OFF);
                        _selectedItems.clear();
                      }
                      return false;
                    }else{
                      Directory currentDir = Directory(currentPath);
                      Directory widgetPathDir = Directory(widget.parentMedium.path);
                      String newPath = currentDir.parent.path;
                      if(videoThumbnails.isNotEmpty){
                        videoThumbnails.clear();
                      }
                      if(newPath == widgetPathDir.parent.path){
                        return true;
                      }else {
                        bloc.folderPath.add(newPath);
                      }
                      return false;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.025, width * 0.04, 0),
                    width: width,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 245, 248, 1),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                    ),
                    child: StreamBuilder<UnmodifiableListView<FileSystemEntity>>(
                      stream: bloc.contents,
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          return GridView.builder(
                            controller: _scrollController,
                            physics: BouncingScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: width * 0.025,
                                mainAxisSpacing: height * 0.01,
                                childAspectRatio: 0.95
                            ),
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index){
                              FileSystemEntity entity = snapshot.data[index];
                              return GridTileView(
                                key: Key('${entity.path}'),
                                bloc: bloc,
                                entity: entity,
                                selectionMode: selectionMode,
//                                selectionBloc: selectionBloc,
                                selectedItems: _selectedItems,
                                selectionModeSetter: selectionModeSetter,
                                thumbnailProvider: thumbnailProvider,
                              );
                            },
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          AnimatedBottomBar(
            controller1: controller1,
            controller2: controller2,
            selectionModeController: selectionModeController,
            selectionMode: selectionMode,
            selectedItems: _selectedItems,
            bloc: widget.bloc,
          ),
        ],
      ),
    );
  }
}

