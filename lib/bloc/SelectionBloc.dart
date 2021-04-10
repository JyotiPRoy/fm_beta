import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart';
import 'package:mime_type/mime_type.dart';

//class SingleChildPropertiesData {
//  final String _title;
//  final String _type;
//  final Map<String,int> _contents;
//  final String _path;
//  final int _size;
//  final DateTime _lastModified;
//
//  SingleChildPropertiesData(
//      this._title,
//      this._type,
//      this._contents,
//      this._path,
//      this._size,
//      this._lastModified
//      ) : assert(_type == null || _contents == null);
//
//  String get title => this._title;
//  String get type => this._type;
//  Map<String,int> get contents => this._contents;
//  String get path => this._path;
//  int get size => this._size;
//  DateTime get lastModified => this._lastModified;
//}
//
//class MultiChildPropertiesData {
//  final String _title;
//  final Map<String,int> _contents;
//  final String _parentPath;
//  final int _size;
//
//  MultiChildPropertiesData(
//      this._title,
//      this._contents,
//      this._parentPath,
//      this._size
//      );
//
//  String get title => this._title;
//  Map<String,int> get contents => this._contents;
//  String get parentPath => this._parentPath;
//  int get size => this._size;
//}
//
//class SelectionBloc {
//  final _selectedItemsSubject = BehaviorSubject<Map<Key,FileSystemEntity>>();
//  final _propertiesDataController = StreamController<dynamic>();
//
//  Map<Key,FileSystemEntity> _selectedItems = <Key,FileSystemEntity>{};
//
//  SelectionBloc(){
//    _selectedItemsSubject.stream.listen((itemsMap){
//      if(itemsMap.isNotEmpty){
//        if(itemsMap.length == 1){
//          _updatePropertiesDataStream(isSingleSelected: true);
//        }else _updatePropertiesDataStream(isSingleSelected: false);
//      }
//    });
//  }
//
//  Future<void> _updatePropertiesDataStream({bool isSingleSelected}) async{
//    var propertiesData;
//    if(isSingleSelected){
//      propertiesData = await _getSingleChildData();
//      _propertiesDataController.add(propertiesData);
//    }else{
//      propertiesData = _getMultiChildData();
//      _propertiesDataController.add(propertiesData);
//    }
//  }
//
//  Future<SingleChildPropertiesData> _getSingleChildData() async{
//    FileSystemEntity entity = _selectedItems.values.elementAt(0);
//    SingleChildPropertiesData propertiesData;
//    String title =  FileUtils.getClippedString(initTitle: basename(entity.path), stringLimit: 70);
//    String path =  entity.path;
//    int size;
//    DateTime lastMod;
//    if(entity is File){
//      String type;
//      type = (mime(entity.path) ?? '');
//      size = await entity.length();
//      lastMod = await entity.lastModified();
//      propertiesData = SingleChildPropertiesData(title,type,null,path,size,lastMod);
//      return propertiesData;
//    }else if(entity is Directory){
//      Map<String,int> contents = await compute<Directory, Map<String,int>>(
//        FileUtils.directoryContentsStats,
//        entity
//      );
//      size = await compute<Directory,int>(
//        FileUtils.sizeOfDirectory,
//        entity
//      );
////      lastMod = await compute<Directory, DateTime>(
////        FileUtils.lastModifiedDirectory,
////        entity
////      );
//      lastMod = DateTime.now();
//      propertiesData = SingleChildPropertiesData(title,null,contents,path,size,lastMod);
//      return propertiesData;
//    }else return null;
//  }
//
//  Future<MultiChildPropertiesData> _getMultiChildData() async{
//    MultiChildPropertiesData propertiesData;
//    String title = '${_selectedItems.length} Items Selected';
//    String parentPath = _selectedItems.values.firstWhere((entity) => entity is Directory).parent.path;
//    int size = 0;
//    Map<String,int> contents;
//    int files = 0, folders = 0;
//    for(FileSystemEntity entity in _selectedItems.values){
//      if(entity is File){
//        files++;
//        size += entity.lengthSync();
//      }else if(entity is Directory){
//        contents = FileUtils.directoryContentsStats(entity);
//        files += contents['Files'];
//        folders += contents['Directories'];
//        size += FileUtils.sizeOfDirectory(entity);
//        contents.clear();
//      }
//    }
//    propertiesData = MultiChildPropertiesData(title,contents,parentPath,size);
//    return propertiesData;
//  }
//
//
//  Stream<Map<Key,FileSystemEntity>> get selectedItems => _selectedItemsSubject.stream;
//  Stream<dynamic> get propertiesData => _propertiesDataController.stream;
//
//
//  void addSelection(MapEntry<Key,FileSystemEntity> entry){
//    if(!_selectedItems.containsKey(entry.key)){
//      _selectedItems[entry.key] = entry.value;
//      _selectedItemsSubject.add(_selectedItems);
//    }
//  }
//
//  void removeSelection(Key key){
//    if(_selectedItems.containsKey(key)){
//      _selectedItems.remove(key);
//      _selectedItemsSubject.add(_selectedItems);
//    }
//  }
//
//  void clearAllSelection(){
//    _selectedItems.clear();
//    _selectedItemsSubject.add(_selectedItems);
//  }
//}