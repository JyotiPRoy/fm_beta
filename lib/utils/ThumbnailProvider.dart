import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:developer' as dev;

import 'package:bitmap/bitmap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fm_beta/utils/IconProvider.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailProvider {
  static Directory tempDir = Directory('/data/user/0/com.example.fm_beta/cache');
  static int maxIsolates = (Platform.numberOfProcessors - 2);
  Map<String, Completer> _thumbnailCompleterMap = <String, Completer>{};
  Queue<String> _requestRegister; // LIFO (stack) of thumbnail requests, addLast & removeLast
  List<Isolate> _isolates;
  List<SendPort> _sendPorts;
  List<ReceivePort> _receivePorts;
  Queue<int> _freeIsolates;
  ScrollController _scrollController;
  bool hasScrolled = false;

  ThumbnailProvider(){
    _requestRegister = Queue<String>();
    _isolates = <Isolate>[];
    _sendPorts = <SendPort>[];
    _receivePorts = <ReceivePort>[];
    _freeIsolates = Queue<int>();
    spawnIsolates();
  }

  void spawnIsolates() async {
    for (int i = 0; i < maxIsolates; i++){
      final receivePort = ReceivePort();
      _receivePorts.add(receivePort);
      receivePort.listen(_handleMessage);
      Isolate isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
      _isolates.add(isolate);
      _freeIsolates.add(i);
    }
    allocateProcessing();
  }

  void setScrollController(ScrollController scrollController){
    _scrollController = scrollController;
  }

  // Allocates a thumbnail processing to an available isolate
  // Wanted to avoid polling, but couldn't T_T
  // TODO: Find an alternative to polling!
  void allocateProcessing(){
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if(_requestRegister.isNotEmpty){
        while(_freeIsolates.isNotEmpty){
          int isolateID = _freeIsolates.removeFirst();
          String imagePath = _scrollController.offset > 0 ? _requestRegister.removeLast() : _requestRegister.removeFirst();
          File image = File(imagePath);
          _sendPorts[isolateID].send(MapEntry<int, File>(isolateID, image));
        }
      }
    });
  }

  Future<dynamic> fetchThumbnails({FileSystemEntity entity}) async {
    if (entity is File){
      String type = (mime(entity.path) ?? '').split('/')[0];
      switch(type){
        case 'image':{
          String fileName = basename(entity.path);
          String thumbnailPath = '${tempDir.path}/' + '$fileName.png';
          if (File(thumbnailPath).existsSync()) {
            return File(thumbnailPath);
          }else{
            if(! _requestRegister.contains(entity.path)){
              _requestRegister.addLast(entity.path);
            }
            var completer = Completer<File>();
            _thumbnailCompleterMap[entity.path] = completer;
            return completer.future;
          }
          break;
        }
        case 'video':{
          break;
        }
      }
    }else if(entity is Directory){
      return false;
    }
  }

  static void _isolateEntry(dynamic message) async {
    SendPort sendPort;
    final receivePort = ReceivePort();
    receivePort.listen((dynamic message) async {
      if (message is MapEntry<int, File>) {
        var file = message.value;
        var id = message.key;
        _getImageThumbnail(file, sendPort, id);
      }
    });
    if (message is SendPort) {
      sendPort = message;
      sendPort.send(receivePort.sendPort);
      return;
    }
  }

  static void _getImageThumbnail(File entity, SendPort sendPort, int id) async {
    String fileName = basename(entity.path);
    String thumbnailPath = '${tempDir.path}/' + '$fileName.png';
    File thumbnail;
    thumbnail = File(thumbnailPath);
    var thumbnailImage = copyResize(decodeImage(entity.readAsBytesSync()), width: 256);
    thumbnail.writeAsBytesSync(encodePng(thumbnailImage));
    MapEntry thumbnailEntry = MapEntry<MapEntry<String, int>, File>(MapEntry<String, int>(entity.path, id), thumbnail);
    sendPort.send(thumbnailEntry);
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      SendPort sendPort = message;
      _sendPorts.add(sendPort);
      // Isolate is Ready
      return;
    } else if (message is MapEntry<MapEntry<String, int>, File>){
      String path = message.key.key;
      int id = message.key.value;
      _freeIsolates.add(id);
      if(_thumbnailCompleterMap.containsKey(path)){
        _thumbnailCompleterMap[path].complete(message.value);
      }
      return;
    }
  }

  void dispose() {
    for(int i=0; i<maxIsolates; i++){
      _isolates[i].kill();
    }
    _freeIsolates.clear();
    _requestRegister.clear();
    _thumbnailCompleterMap.clear();
  }
}

// class ThumbnailProvider {
//   final _isolateReady = Completer<void>();
//   static Directory tempDir = Directory('/data/user/0/com.example.fm_beta/cache');
//   Map _thumbnailCompleterMap;
//   SendPort _sendPort;
//   Isolate _isolate;
//   static MethodChannel platformCaller = MethodChannel('com.example.fm_beta');
//   static bool useNativeMethod = false;
//
//
//   ThumbnailProvider(){
//     init();
//   }
//
//   Future<void> init() async {
//     _thumbnailCompleterMap = Map<String, Completer<File>>();
//     final receivePort = ReceivePort();
//     receivePort.listen(_handleMessage);
// //    tempDir = await getTemporaryDirectory();
//     _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
//   }
//
//   Future<dynamic> fetchThumbnails({FileSystemEntity entity}) async{
//     if(entity is File){
//       String type = (mime(entity.path) ?? '').split('/')[0];
//       switch(type){
//         case 'image': {
//           break;
//         }
//         case 'video' : {
//           break;
//         }
//       }
//     }else if(entity is Directory){
//       return false;
//     }
//   }
//
//   Future<void> get isolateReady => _isolateReady.future;
//
//     static void _getImageThumbnail(File entity, SendPort sendPort) async{
//     String fileName = basename(entity.path);
//     String thumbnailPath = '${tempDir.path}/' + '$fileName.png';
//     File thumbnail;
//     if(File(thumbnailPath).existsSync()){
//       thumbnail = File(thumbnailPath);
//     }else {
//       if(useNativeMethod){
//         var test = await platformCaller.invokeMethod('getThumbnail', {"path":fileName, "thumbnailPath":thumbnailPath});
//         dev.log('OUTPUT: $test');
//       }else{
//         thumbnail = File(thumbnailPath);
//         Image thumbnailImage = copyResize(decodeImage(entity.readAsBytesSync()), width: 256);
//         thumbnail.writeAsBytesSync(encodePng(thumbnailImage));
//       }
//     }
//     MapEntry thumbnailEntry = MapEntry<String, File>(entity.path, thumbnail);
//     sendPort.send(thumbnailEntry);
//   }
//
//   static void _isolateEntry(dynamic message) async{
//       SendPort sendPort;
//       final receivePort = ReceivePort();
//       receivePort.listen((dynamic message) async{
//         if(message is File){
//           _getImageThumbnail(message, sendPort);
//        }
//       });
//       if(message is SendPort){
//         sendPort = message;
//         sendPort.send(receivePort.sendPort);
//         return;
//       }
//   }
//
//   void _handleMessage(dynamic message) {
//     if(message is SendPort){
//       _sendPort = message;
//       _isolateReady.complete();
//       return;
//     }else if(message is MapEntry<String, File>){
//       String path = message.key;
//       if(_thumbnailCompleterMap.containsKey(path)){
//         Completer<File> completer = _thumbnailCompleterMap[path];
//         completer.complete(message.value);
//       }
//       return;
//     }
//   }
//
//   void dispose(){
//     _thumbnailCompleterMap.clear();
//     _isolate.kill();
//   }
// }
