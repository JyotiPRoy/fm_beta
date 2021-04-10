import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collection/collection.dart';
import 'package:fm_beta/bloc/SelectionBloc.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:fm_beta/utils/IconProvider.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class PropertiesViewer extends StatefulWidget {
  final Map<Key, FileSystemEntity> selectedItems;
  final FileUtils fileUtils;
  final Animation expandAnimation;
  final AnimationController expansionController;

  PropertiesViewer(
      {@required this.selectedItems,
      @required this.fileUtils,
      @required this.expandAnimation,
      this.expansionController});

  @override
  _PropertiesViewerState createState() => _PropertiesViewerState();
}

class _PropertiesViewerState extends State<PropertiesViewer> {
  Widget contents;

  @override
  void initState() {
    super.initState();
    contents = _PropertiesViewerContents(
      selectedItems: widget.selectedItems,
      fileUtils: widget.fileUtils,
    );
  }

  @override
  void didUpdateWidget(PropertiesViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    var oldMap = oldWidget.selectedItems;
    var newMap = widget.selectedItems;
    if(DeepCollectionEquality().equals(oldMap,newMap)){
      setState(() {
        contents = _PropertiesViewerContents(
          selectedItems: newMap,
          fileUtils: widget.fileUtils,
        );
      });
    }
  }

  @override
  void dispose() {
    contents = SizedBox();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: widget.expandAnimation,
      builder: (context, _) {
        return Container(
            height: height * widget.expandAnimation.value,
            margin: EdgeInsets.fromLTRB(
                width * 0.03, 0, width * 0.03, height * 0.006),
            child: Column(
              children: <Widget>[
                contents,
                Container(
                  height: 1,
                  width: width * 0.82,
                  color: Colors.grey[600],
                )
              ],
            ));
      },
    );
  }
}

class _PropertiesViewerContents extends StatelessWidget {
  final Map<Key, FileSystemEntity> selectedItems;
  final FileUtils fileUtils;

  _PropertiesViewerContents({@required this.selectedItems, @required this.fileUtils});

  Future<int> get _size async{
    int size = 0;
    for(FileSystemEntity entity in selectedItems.values){
      if(entity is File){
        size += await entity.length();
      }else if(entity is Directory){
        size += await fileUtils.sizeofContents(path: entity.path);
      }
    }
    return size;
  }

  Future<DateTime> get _lastModified async{
    return DateTime.now();
  }

  Future<Map<String,int>> get _contents async{
    int files = 0, folders = 0;
    Map<String,int> contents;
    for(FileSystemEntity entity in selectedItems.values){
      if(entity is File){
        files++;
      }else if(entity is Directory){
        contents = await fileUtils.directoryContents(path: entity.path);
        files += contents['Files'];
        folders += contents['Directories'];
        contents.clear();
      }
    }
    return {'Files': files, 'Directories': folders};
  }



  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    List<Widget> contentsBody = <Widget>[];
    TextStyle contentStyle = TextStyle(color: Colors.white, fontSize: 12);
    Container separator = Container(height: 1, width: width * 0.55, color: Colors.grey[600],);

    if (selectedItems.length == 1) {
      FileSystemEntity singleEntity = selectedItems[selectedItems.keys.elementAt(0)];
      Text title = Text(
          '${FileUtils.getClippedString(initTitle: basename(singleEntity.path), stringLimit: 70)}',
          style: TextStyle(color: Colors.white, fontSize: 16));
      Container separator = Container(height: 1, width: width * 0.55, color: Colors.grey[600],);
      Row path = Row(
        children: <Widget>[
          Text(
            'Path: ${FileUtils.getClippedString(initTitle: singleEntity.path, stringLimit: 25)}',
            style: contentStyle,
          ),
          SizedBox(
            width: 4,
          ),
          Icon(
            Icons.content_copy,
            color: Colors.white,
            size: 18,
          )
        ],
      );
      if(singleEntity is File){
        Text type = Text('Type: ${mime(singleEntity.path)}', style: contentStyle);
        Text size = Text(
            'Size: ${FileUtils.formatBytes(singleEntity.lengthSync(), 1)}',
          style: contentStyle,
        );
        Text lastMod = Text(
          'Last Modified: ${FileUtils.formatTime(lastModifiedTime: singleEntity.lastModifiedSync())}',
          style: contentStyle,
        );
        contentsBody.addAll([title, separator, type, path, size, lastMod]);
      }else if(singleEntity is Directory){
        FutureBuilder contents = FutureBuilder<Map<String,int>>(
          future: _contents,
          builder: (context,snapshot){
            if(snapshot.hasData){
              String folders = snapshot.data['Directories'] != 0 ? '${snapshot.data['Directories']} Folders' : '';
              String files = snapshot.data['Files'] != 0 ? '${snapshot.data['Files']} Files' : '';
              return Text(
                'Contents: $folders, $files',
                style: contentStyle,
              );
            }if(snapshot.connectionState == ConnectionState.waiting){
              return Text('Contents: Loading...', style: contentStyle,);
            }return Text('Contents: N/A', style: contentStyle,);
          },
        );
        FutureBuilder size = FutureBuilder<int>(
          future: _size,
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Text('Size: ${FileUtils.formatBytes(snapshot.data, 1)}', style: contentStyle,);
            }if(snapshot.connectionState == ConnectionState.waiting){
              return Text('Size: Loading...', style: contentStyle,);
            }return Text('Size: N/A', style: contentStyle,);
          },
        );
        FutureBuilder lastMod = FutureBuilder<DateTime>(
          future: _lastModified,
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Text('Last Modified: ${FileUtils.formatTime(lastModifiedTime: snapshot.data)}', style: contentStyle,);
            }if(snapshot.connectionState == ConnectionState.waiting){
              return Text('Last Modified: Loading...', style: contentStyle,);
            }return Text('Last Modified: N/A', style: contentStyle,);
          },
        );
        contentsBody.addAll([title, separator, contents, path, size, lastMod]);
      }
    }else{
      Text title = Text(
          '${selectedItems.length} Items Selected',
          style: TextStyle(color: Colors.white, fontSize: 16));
      Container separator = Container(height: 1, width: width * 0.55, color: Colors.grey[600],);
      Row parentPath = Row(
        children: <Widget>[
          Text(
            'Parent Path: ${FileUtils.getClippedString(initTitle: selectedItems.values.elementAt(0).parent.path, stringLimit: 25)}',
            style: contentStyle,
          ),
          SizedBox(
            width: 4,
          ),
          Icon(
            Icons.content_copy,
            color: Colors.white,
            size: 18,
          )
        ],
      );
      FutureBuilder contents = FutureBuilder<Map<String,int>>(
        future: _contents,
        builder: (context, snapshot){
          if(snapshot.hasData){
            String folders = snapshot.data['Directories'] != 0 ? '${snapshot.data['Directories']} Folders' : '';
            String files = snapshot.data['Files'] != 0 ? '${snapshot.data['Files']} Files' : '';
            return Text(
              'Contents: $folders, $files',
              style: contentStyle,
            );
          }if(snapshot.connectionState == ConnectionState.waiting){
            return Text('Contents: Loading...', style: contentStyle,);
          }return Text('Contents: N/A', style: contentStyle,);
        },
      );
      FutureBuilder size = FutureBuilder<int>(
        future: _size,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return Text('Size: ${FileUtils.formatBytes(snapshot.data, 1)}', style: contentStyle,);
          }if(snapshot.connectionState == ConnectionState.waiting){
            return Text('Size: Loading...', style: contentStyle,);
          }return Text('Size: N/A', style: contentStyle,);
        },
      );
      contentsBody.addAll([title, separator, parentPath, contents, size]);
    }

    return Container(
      height: height * 0.2,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Container(
                  height: height * 0.135,
                  width: width * 0.2,
                  child: selectedItems.length == 1
                  ? Transform.rotate(
                    alignment: FractionalOffset.center,
                    angle: -(pi / 16),
                    child: SvgPicture.asset(IconProvider.getIcon(selectedItems.values.elementAt(0))),
                  )
                  : SvgPicture.asset('assets/icons/multiple_files.svg'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              padding: EdgeInsets.all(6),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: contentsBody,
             ),
            ),
          )
        ],
      ),
    );
  }
}

