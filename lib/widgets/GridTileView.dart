import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as dev;

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/pages/DirectoryViewPage.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:fm_beta/utils/IconProvider.dart';
import 'package:fm_beta/utils/IntentHandler.dart';
import 'package:fm_beta/utils/ThumbnailProvider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class GridTileView extends StatefulWidget {
  final FileSystemEntity entity;
  final FileSystemBloc bloc;
  final Map<Key,FileSystemEntity> selectedItems;
  final ThumbnailProvider thumbnailProvider;
  final Sink<SelectionMode> selectionModeSetter;
  final SelectionMode selectionMode;


  GridTileView(
      {Key key,
      @required this.bloc,
      @required this.entity,
      @required this.selectedItems,
      @required this.selectionMode,
      @required this.selectionModeSetter,
      @required this.thumbnailProvider})
      : assert(key != null),
        super(key: key);

  @override
  _GridTileViewState createState() => _GridTileViewState();
}

class _GridTileViewState extends State<GridTileView> {
  bool isSelected;
  ThumbnailProvider thumbnailProvider;
  FileSystemBloc bloc;
  SelectionMode selectionMode;

  @override
  void initState() {
    super.initState();
    isSelected = widget.selectedItems.containsKey(widget.key);
    bloc = widget.bloc;
    thumbnailProvider = widget.thumbnailProvider;
    selectionMode = widget.selectionMode;
  }

  @override
  void didUpdateWidget(GridTileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.selectionMode != widget.selectionMode){
      setState(() {
        selectionMode = widget.selectionMode;
        isSelected = widget.selectedItems.containsKey(widget.key);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onLongPress: () {
        setState(() {
          if (selectionMode == SelectionMode.ON) {
            isSelected = false;
            selectionMode = SelectionMode.OFF;
            widget.selectionModeSetter.add(SelectionMode.OFF);
            widget.selectedItems.clear();
//            widget.selectionBloc.clearAllSelection();
          }else if(selectionMode == SelectionMode.isCopying){
            ///TODO: Add Toast
          }else {
            isSelected = true;
            widget.selectedItems[widget.key] = widget.entity;
//            widget.selectionBloc.addSelection(MapEntry<Key,FileSystemEntity>(widget.key,widget.entity));
            selectionMode = SelectionMode.ON;
            widget.selectionModeSetter.add(SelectionMode.ON);
          }
        });
      },
      onTap: () {
        if (selectionMode == SelectionMode.ON) {
          if (isSelected) {
            setState(() {
              isSelected = false;
              widget.selectedItems.remove(widget.key);
//              widget.selectionBloc.removeSelection(widget.key);
            });
          } else {
            setState(() {
              isSelected = true;
              widget.selectedItems[widget.key] = widget.entity;
//              widget.selectionBloc.addSelection(MapEntry<Key,FileSystemEntity>(widget.key,widget.entity));
            });
          }
        } else {
          if (widget.entity is Directory) {
            bloc.folderPath.add(widget.entity.path);
          } else if (widget.entity is File && selectionMode != SelectionMode.isCopying) {
            String type = mime(widget.entity.path);
            if (type != null) {
              print('TYPE: $type');
              // AndroidIntent openFile = AndroidIntent(
              //     action: 'action_view',
              //     data: Uri.encodeFull(widget.entity.path),
              //     type: type,
              // );
              // openFile.launch();
              IntentHandler handler = IntentHandler(
                intentType: IntentType.Open,
                data: widget.entity.path,
                mimeType: type
              );
              handler.launch();
            } else
              print('Failed to open!');
          }
        }
      },
      child: Stack(
        children: <Widget>[
          Container(
            height: height * 0.135,
            width: width * 0.29,
            decoration: BoxDecoration(
              color: Color.fromRGBO(235, 238, 243, 1),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.012),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: height * 0.065,
                      width: width * 0.18,
                      child: FutureBuilder(
                        future: thumbnailProvider.fetchThumbnails(
                            entity: widget.entity),
                        initialData: SvgPicture.asset(
                          IconProvider.getIcon(widget.entity),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data is Uint8List) {
                              dev.log('IMAGE LENGTH: ${snapshot.data.length}');
                              return FittedBox(
                                child: Image.memory(snapshot.data),
                                fit: BoxFit.fitWidth,
                              );
                            } else if(snapshot.data is File){
                              dev.log('FILE_IMG: ${snapshot.data.path}');
                              return FittedBox(
                                child: Image.file(snapshot.data),
                                fit: BoxFit.fitWidth,
                              );
                            }else if (snapshot.data is String) {

                              ///TODO: REPAIR VIDEO THUMBNAIL PROVIDER & RELATED ISSUES

//                            Uint8List thumbnail = snapshot.data;
                              var thumbnail = SvgPicture.asset(snapshot.data);
//                            videoThumbnails.add(thumbnail);
                              return Container(
                                child: Stack(
                                  children: <Widget>[
                                    Center(
                                      child: thumbnail, //Image.memory(thumbnail),
                                    ),
//                                  Center(
//                                    child: Icon(
//                                      FontAwesomeIcons.play,
//                                      color: Color.fromRGBO(255, 255, 255, 0.9),
//                                      size: 18,
//                                    ),
//                                  )
                                  ],
                                ),
                              );
                            }
                          }
                          return SvgPicture.asset(
                            IconProvider.getIcon(widget.entity),
                          );
                        },
                      ),
                  ),
                  SizedBox(
                    height: height * 0.005,
                  ),
                  Text(
                    '${FileUtils.getClippedString(initTitle: basename(widget.entity.path), stringLimit: 14)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Montserrat'),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: selectionMode == SelectionMode.ON ? true : false,
            child: Positioned(
              bottom: 50,
              right: 10,
              child: Container(
                  alignment: Alignment.center,
                  height: 19,
                  width: 19,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey[500],
                          width: 2),
                      color: Colors.grey[100],
                      shape: BoxShape.circle),
                  child: Icon(
                    FontAwesomeIcons.check,
                    color: isSelected ? Colors.green : Colors.grey[100],
                    size: 10,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
