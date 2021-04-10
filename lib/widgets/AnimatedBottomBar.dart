import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/BlocProvider.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/pages/DirectoryViewPage.dart';
import 'package:fm_beta/utils/FileActions.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:fm_beta/utils/IntentHandler.dart';
import 'package:fm_beta/widgets/FMDialogWidget.dart';
import 'package:fm_beta/widgets/PropertiesViewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';

class AnimatedBottomBar extends StatefulWidget {
  final SelectionMode selectionMode;
  final StreamController<SelectionMode> selectionModeController;
  final Map<Key,FileSystemEntity> selectedItems;
  final AnimationController controller1, controller2;
  final FileSystemBloc bloc;

  AnimatedBottomBar({
    @required this.selectionMode,
    @required this.selectedItems,
    @required this.selectionModeController,
    @required this.controller1,
    @required this.controller2,
    this.bloc
  });

  static _AnimatedBottomBarState of(BuildContext context) => context.findAncestorStateOfType<_AnimatedBottomBarState>();

  @override
  _AnimatedBottomBarState createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar> with TickerProviderStateMixin {
  SelectionMode selectionMode;
  bool isCopying;
  bool isCutting;
  AnimationController controller1, controller2;
  Animation moreAnimationParent;
  Animation detailsAnimation;
  Animation moreAnimationRow;
  Animation detailsAnimationParent;
  bool moreTapped = false;
  bool detailsTapped = false;
  bool renameTapped = false;
  Widget propertiesViewer;
  FileUtils fileUtils;
  FileActions fileActions;
  Stream<double> progress;

  @override
  void initState() {
    super.initState();
    fileActions = FileActions(bloc: widget.bloc, selectionModeController: widget.selectionModeController);
    progress = fileActions.progress;
    selectionMode = widget.selectionMode;
    isCopying = false;
    isCutting = false;
    controller1 = widget.controller1;
    controller2 = widget.controller2;
    moreAnimationParent = Tween<double>(begin: 0.1, end: 0.2).animate(controller1);
    moreAnimationRow = Tween<double>(begin: 0, end: 0.1).animate(controller1);
    detailsAnimation = Tween<double>(begin: 0, end: 0.205).animate(controller2);
    detailsAnimationParent = Tween<double>(begin: 0.2, end: 0.41).animate(controller2);
    propertiesViewer = SizedBox(height: 4,);
    initFileUtils();
    controller2.addStatusListener((status){
      if(status == AnimationStatus.dismissed){
        setState(() {
          detailsTapped = false;
        });
      }
    });
    controller1.addStatusListener((status){
      if(status == AnimationStatus.reverse){
        if(moreTapped != false){
          setState(() {
            moreTapped = false;
          });
        }
      }
    });
    widget.selectionModeController.stream.listen((mode) {
      if(mode == SelectionMode.OFF){
        setState(() {
          isCopying = false;
        });
      }
    });
  }

  Future<void> initFileUtils() async{
    fileUtils = FileUtils();
    await fileUtils.isolateReady;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.selectionMode != widget.selectionMode){
      setState(() {
        setState(() {
          selectionMode = widget.selectionMode;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;


    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastLinearToSlowEaseIn,
      bottom: height * (selectionMode == SelectionMode.ON ? 0.008 : (isCopying ? 0.008 : -0.108)),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: AnimatedBuilder(
            animation: moreTapped ? detailsAnimationParent : moreAnimationParent,
            builder: (context, _){
              return Container(
//                padding: EdgeInsets.symmetric(vertical: height * 0.0135),
                height: height * (moreTapped ? detailsAnimationParent.value : moreAnimationParent.value),
                width: width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.grey[900].withOpacity(0.7),
                ),
                child: Stack(
                  children: <Widget>[
                    propertiesViewer,
                    Positioned(
                      bottom: (height * 0.075 + 10),
                      child: AnimatedBuilder(
                        animation: moreAnimationRow,
                        builder: (context, _){
                          return Opacity(
                            opacity: moreAnimationRow.value * 10,
                            child: Container(
                              margin: EdgeInsets.only(bottom: height * 0.008),
                              height: height * moreAnimationRow.value,
                              width: width * 0.95,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: (){
                                          fileActions.share(entitiesToShare: widget.selectedItems.values.toList());
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[900]
                                          ),
                                          child: Icon(FontAwesomeIcons.shareAlt, color: Colors.white, size: 18,),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text('Share', style: TextStyle(color: Colors.white, fontSize: 12),)
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[900]
                                        ),
                                        child: Icon(FontAwesomeIcons.eyeSlash, color: Colors.white, size: 18),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text('Hide', style: TextStyle(color: Colors.white, fontSize: 12),)
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[900]
                                        ),
                                        child: Icon(FontAwesomeIcons.fileArchive, color: Colors.white, size: 18),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text('Archive', style: TextStyle(color: Colors.white, fontSize: 12),)
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      InkWell(
                                        onTap:(){
                                          if(detailsTapped){
                                            controller2.reverse().then((_){
                                              setState(() {
                                                detailsTapped = false;
                                                propertiesViewer = SizedBox(height: 4,);
                                              });
                                            });
                                          }else{
                                            ///TODO: Control PropertiesViewer visibility
                                            setState(() {
                                              propertiesViewer = PropertiesViewer(
                                                selectedItems: widget.selectedItems,
                                                fileUtils: fileUtils,
                                                expandAnimation: detailsAnimation,
                                              );
                                            });
                                            controller2.forward().then((_){
                                              setState(() {
                                                detailsTapped = true;
                                              });
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[900]
                                          ),
                                          child: Icon(FontAwesomeIcons.info, color: Colors.white, size: 18),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text('Details', style: TextStyle(color: Colors.white, fontSize: 12),),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[900]
                                        ),
                                        child: Icon(FontAwesomeIcons.heart, color: Colors.white, size: 18),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text('Fav', style: TextStyle(color: Colors.white, fontSize: 12),)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                   Positioned(
                     bottom: 10,
                     child: AnimatedSwitcher(
                       duration: const Duration(milliseconds: 350),
                       child: isCopying
                           ? _PasteRow(
                                cancelTapped: _cancelEventHandler,
                                selectedItems: widget.selectedItems,
                                pasteTapped: (){
                                  print('PASTE TAPPED!');
                                  return _pasteEventHandler(context);
                                },
                                progressStream: progress,
                            )
                           : _BottomRow(
                                selectedItems: widget.selectedItems,
                                moreTapped: _moreEventHandler,
                                copyTapped: _copyEventHandler,
                                detailsTapped: detailsTapped,
                                deleteTapped: (){
                                  return _deleteEventHandler(context);
                                },
                                renameTapped: (){
                                  if(widget.selectedItems.length > 1){
                                    return _batchRenameEventHandler(context);
                                  }else {
                                    FileSystemEntity selectedEntity = widget.selectedItems.values.first;
                                    widget.selectionModeController.add(SelectionMode.OFF);
                                    return _renameEventHandler(context, selectedEntity);
                                  }
                                },
                            ),
                     ),
                   )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _cutEventHandler() {
    setState(() {
      isCopying = true;
      isCutting = true;
    });
    widget.selectionModeController.add(SelectionMode.isCopying);
  }

  void _copyEventHandler() {
    setState(() {
      isCopying = true;
    });
    widget.selectionModeController.add(SelectionMode.isCopying);
  }

  void _cancelEventHandler(){
    fileActions.cancel();
    widget.selectedItems.clear();
  }

  void _pasteEventHandler(BuildContext context) async{
    print('PASTE EVENT START!');
    fileActions.copy(entityList: widget.selectedItems.values.toList(), context: context);
    widget.selectedItems.clear();
  }

  void _deleteEventHandler(BuildContext context) async{
    FileSystemBloc bloc = BlocProvider.of(context).bloc;
    FMDialog deleteDialog = FMDialog(
      dialogType: DialogType.Confirmation,
      title: 'Delete Selected Item?',
      content: 'Do you want to Permanently Delete the Selected Items?',
      okTapped: (){
        String parentPath = widget.selectedItems.values.first.parent.path;
        List<FileSystemEntity> toDelete = widget.selectedItems.values.toList();
        for(FileSystemEntity entity in toDelete){
          entity.deleteSync(recursive: true);
        }
        Navigator.pop(context);
        widget.selectionModeController.add(SelectionMode.OFF);
        widget.selectedItems.clear();
        bloc.folderPath.add(parentPath);
      },
      cancelTapped: (){
        Navigator.pop(context);
      },
    );
    await showDialog<FMDialog>(
      context: context,
      builder: (context){
        return deleteDialog;
      },
      barrierColor: Colors.grey[900].withOpacity(0.5)
    );
  }

  void _renameEventHandler(BuildContext buildContext, FileSystemEntity entity) async {
    TextEditingController editingController = TextEditingController(text: basename(entity.path));
    FileSystemBloc bloc = BlocProvider.of(buildContext).bloc;
    StreamController<String> content = StreamController<String>();
    FMDialog renameInput = FMDialog(
      dialogType: DialogType.Input,
      title: 'Rename ${entity is File ? 'File' : 'Folder'}',
      content: content.stream,
      editingController: editingController,
      okTapped: () async{
        Completer replaceCheck = Completer<bool>();
        String newName = editingController.text;
        String newPath = entity.parent.path + '/' +newName;
        bloc.contents.listen((contentsList) {
          for(FileSystemEntity item in contentsList){
            if(newName == basename(item.path) && item.path != entity.path){
               content.add('A ${entity is File ? 'File' : 'Folder'} with that name already exists!');
               replaceCheck.complete(true);
            }
          }
          if(!replaceCheck.isCompleted){
            replaceCheck.complete(false);
          }
        });
        if(!(await replaceCheck.future)){
          Navigator. pop(buildContext);
          widget.selectedItems.clear();
          entity = entity is File 
          ? entity.renameSync(newPath)
          : (entity as Directory).renameSync(newPath);
          bloc.folderPath.add(entity.parent.path);
        }
      },
      cancelTapped: (){
        Navigator.pop(buildContext);
        widget.selectedItems.clear();
      },
    );
    await showDialog(
      context: buildContext,
      builder: (context){
        return renameInput;
      },
      barrierColor: Colors.grey[900].withOpacity(0.5)
    );
  }

  void _batchRenameEventHandler(BuildContext context) async{
    FMDialog alertDialog = FMDialog(
      dialogType: DialogType.Alert,
      title: 'Unimplemented Error!',
      content: 'Batch rename has not been implemented yet. Select a single item to rename.',
      okTapped: (){
        Navigator.pop(context);
      },
    );
    await showDialog<FMDialog>(
      context: context,
      builder: (context){
        return alertDialog;
      },
      barrierColor: Colors.grey[900].withOpacity(0.5)
    );
  }

  void _moreEventHandler() {
    if(moreTapped){
      setState(() {
        moreTapped = false;
      });
      controller1.reverse();
    }else{
      controller1.forward().then((_){
        setState(() {
          moreTapped = true;
        });
      });
    }
  }

}


class _BottomRow extends StatefulWidget {
  final GestureTapCallback cutTapped;
  final GestureTapCallback copyTapped;
  final GestureTapCallback deleteTapped;
  final GestureTapCallback renameTapped;
  final GestureTapCallback moreTapped;
  final bool detailsTapped;
  final Map<Key,FileSystemEntity> selectedItems;

  _BottomRow({
    this.cutTapped,
    this.copyTapped,
    this.deleteTapped,
    this.renameTapped,
    this.moreTapped,
    this.detailsTapped,
    this.selectedItems
  });

  @override
  __BottomRowState createState() => __BottomRowState();
}

class __BottomRowState extends State<_BottomRow> {
  bool detailsTapped;

  @override
  void initState() {
    super.initState();
    detailsTapped = widget.detailsTapped;
  }

  @override
  void didUpdateWidget(_BottomRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.detailsTapped != widget.detailsTapped){
      setState(() {
        detailsTapped = widget.detailsTapped;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: height * 0.075,
      width: width * 0.95,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: widget.cutTapped,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900]
                  ),
                  child: Icon(Icons.content_cut, color: Colors.white, size: 18,),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text('Cut', style: TextStyle(color: Colors.white, fontSize: 12),)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: widget.copyTapped,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900]
                  ),
                  child: Icon(Icons.content_copy, color: Colors.white, size: 18),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12),)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: widget.deleteTapped,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900]
                  ),
                  child: Icon(FontAwesomeIcons.trashAlt, color: Colors.white, size: 18),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12),)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: widget.renameTapped,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900]
                  ),
                  child: Icon(FontAwesomeIcons.iCursor, color: Colors.white, size: 18),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text('Rename', style: TextStyle(color: Colors.white, fontSize: 12),),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: detailsTapped ? null : widget.moreTapped,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: detailsTapped ? Colors.grey[700] : Colors.grey[900]
                  ),
                  child: Icon(FontAwesomeIcons.chevronUp, color: detailsTapped ? Colors.grey[500] : Colors.white, size: 18),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text('More', style: TextStyle(color: detailsTapped ? Colors.grey[500] : Colors.white, fontSize: 12),)
            ],
          ),
        ],
      ),
    );
  }
}

class _PasteRow extends StatefulWidget {
  final Map<Key,FileSystemEntity> selectedItems;
  final GestureTapCallback cancelTapped;
  final GestureTapCallback pasteTapped;
  final GestureTapCallback newFolderTapped;
  final Stream<double> progressStream;

  _PasteRow({
    this.cancelTapped,
    this.pasteTapped,
    this.newFolderTapped,
    this.selectedItems,
    this.progressStream
  });

  @override
  __PasteRowState createState() => __PasteRowState();
}

class __PasteRowState extends State<_PasteRow> {
  bool pasteTapped;

  @override
  void initState(){
    super.initState();
    pasteTapped = true;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;



    return Container(
      height: height * 0.075,
      width: width * 0.95,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: height * 0.07,
            width: width * 0.28,
            child: Center(
                child: Text(
                  '${widget.selectedItems.length} ${widget.selectedItems.length > 1 ? 'Items' : 'Item'} in Clipboard',
                  style: TextStyle(color: Colors.white), textAlign: TextAlign.center,
                )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: widget.newFolderTapped,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900]
                  ),
                  child: Icon(FontAwesomeIcons.plus, color: Colors.white, size: 18),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text('Folder', style: TextStyle(color: Colors.white, fontSize: 12),)
            ],
          ),
          SizedBox(
            width: 40,
            child: pasteTapped
            ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: widget.pasteTapped,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[900]
                            ),
                            child: Icon(FontAwesomeIcons.info, color: Colors.white, size: 18),
                          ),
                        ),
                        Positioned.fill(
                          child: Theme(
                            data: ThemeData(primaryColor: Colors.white, accentColor: Colors.grey[200]),
                            child: StreamBuilder<double>(
                                stream: widget.progressStream,
                                builder: (context, snapshot){
                                  if(snapshot.hasData){
                                    return CircularProgressIndicator(
                                      value: snapshot.data,
                                    );
                                  }else if(snapshot.connectionState == ConnectionState.waiting){
                                    return CircularProgressIndicator();
                                  }else return CircularProgressIndicator(value: 1,);
                                }
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text('Info', style: TextStyle(color: Colors.white, fontSize: 12),),
              ],
            )
            : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: widget.pasteTapped,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[900]
                    ),
                    child: Icon(FontAwesomeIcons.paste, color: Colors.white, size: 18),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text('Paste', style: TextStyle(color: Colors.white, fontSize: 12),),
              ],
            )
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: widget.cancelTapped,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900]
                  ),
                  child: Icon(Icons.cancel, color: Colors.white, size: 24),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 12),)
            ],
          ),
        ],
      ),
    );
  }
}

