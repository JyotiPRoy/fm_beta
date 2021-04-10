import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:fm_beta/bloc/BlocProvider.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

enum SortCriteria {
  az,
  za,
  LastModifiedUp,
  LastModifiedDown,
  Extension_az,
  Extension_za,
  SizeAscending,
  SizeDescending
}

enum Category{
  Document,
  Video,
  Music,
  Download,
  Image,
  Archive,
  Apk
}

enum _PropertyIdentifier{
  Size,
  LastModified,
  Contents
}

class FileUtils {
  SendPort _sendPort;
  Isolate _isolate;
  final _isolateReady = Completer<void>();
  Completer _sortedFolder, _sizeCompleter, _lastModCompleter, _contentsCompleter, _filesByCatCompleter;

  FileUtils(){
    init();
  }

  Future<void> init() async {
    final receivePort = ReceivePort();
    receivePort.listen(_handleMessage);
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
  }

  Future<void> get isolateReady => _isolateReady.future;

  Future<List<FileSystemEntity>> sortFolderContents({List list, SortCriteria criteria}) async{
    var message = MapEntry<List<FileSystemEntity>, SortCriteria>(list, criteria);
    _sendPort.send(message);
    _sortedFolder = Completer<List<FileSystemEntity>>();
    return _sortedFolder.future;
  }
  
  Future<int> sizeofContents({String path, List<FileSystemEntity> list}) async{
    var message;
    if(list == null){
      Directory directory = Directory(path);
      message = MapEntry<_PropertyIdentifier,Directory>(_PropertyIdentifier.Size,directory);
    }else message = list;
    _sendPort.send(message);
    _sizeCompleter = Completer<int>();
    return _sizeCompleter.future;
  }

  Future<DateTime> lastModifiedOfDirectory({String path}) async{
    Directory directory = Directory(path);
    MapEntry message = MapEntry<_PropertyIdentifier,Directory>(_PropertyIdentifier.LastModified,directory);
    _sendPort.send(message);
    _lastModCompleter = Completer<DateTime>();
    return _lastModCompleter.future;
  }

  Future<Map<String,int>> directoryContents({String path}) async{
    Directory directory = Directory(path);
    MapEntry message = MapEntry<_PropertyIdentifier,Directory>(_PropertyIdentifier.Contents,directory);
    _sendPort.send(message);
    _contentsCompleter = Completer<Map<String,int>>();
    return _contentsCompleter.future;
  }

  Future<List<FileSystemEntity>> getFilesByCategory({Category category, List<Directory> storageMedia}) async{
    MapEntry<Category,List<Directory>> message = MapEntry<Category,List<Directory>>(category,storageMedia);
    _sendPort.send(message);
    _filesByCatCompleter = Completer<List<FileSystemEntity>>();
    return _filesByCatCompleter.future;
  }

  static void _isolateEntry(dynamic message) {
    SendPort sendPort;
    final receivePort = ReceivePort();

    receivePort.listen((dynamic message) async{
      if(message is MapEntry<List<FileSystemEntity>, SortCriteria>){
        List<FileSystemEntity> sortedFolder = _sortFolderContents(list: message.key, criteria: message.value);
        sendPort.send(sortedFolder);
      }else if(message is MapEntry<_PropertyIdentifier,Directory>){
        var identifier = message.key;
        switch(identifier){
          case _PropertyIdentifier.Size:{
            int size = _sizeOfContents(directory: message.value);
            sendPort.send(size);
            break;
          }
          case _PropertyIdentifier.LastModified:{
            DateTime lastMod = _lastModifiedDirectory(message.value);
            sendPort.send(lastMod);
            break;
          }
          case _PropertyIdentifier.Contents:{
            Map<String,int> contents = _directoryContentsStats(message.value);
            sendPort.send(contents);
            break;
          }
          default: break;
        }
      }else if(message is MapEntry<Category,List<Directory>>){
        List<FileSystemEntity> files = await _filesByCategory(category: message.key, storageMedia: message.value);
        MapEntry returnVal = MapEntry<List<FileSystemEntity>, Category>(files,message.key);
        sendPort.send(returnVal);
      }else if(message is List<FileSystemEntity>){
        int size = _sizeOfContents(list: message);
        sendPort.send(size);
      }
    });

    if(message is SendPort){
      sendPort = message;
      sendPort.send(receivePort.sendPort);
      return;
    }
  }

  void _handleMessage(dynamic message) {
    if(message is SendPort){
      _sendPort = message;
      _isolateReady.complete();
      return;
    }else if(message is List<FileSystemEntity>){
      _sortedFolder.complete(message);
      _sortedFolder = null;
      return;
    }else if(message is int){
      _sizeCompleter.complete(message);
      _sizeCompleter = null;
      return;
    }else if(message is DateTime){
      _lastModCompleter.complete(message);
      _lastModCompleter = null;
      return;
    }else if(message is Map<String,int>){
      _contentsCompleter.complete(message);
      _contentsCompleter = null;
      return;
    }else if(message is MapEntry<List<FileSystemEntity>, Category>){
      _filesByCatCompleter.complete(message.key);
      _filesByCatCompleter = null;
      return;
    }
  }

  static List<FileSystemEntity> _sortFolderContents({List<FileSystemEntity> list, SortCriteria criteria}) {
    ///TODO: Read more about how parameters are passed to function in dart, by value or by reference
    List<FileSystemEntity> returnVal = list;
    returnVal.sort((a,b){
      if(a is File && b is Directory){
        return 1;
      } else if(a is Directory && b is File){
        return -1;
      } else if(a is File && b is File){
        switch(criteria){
          case SortCriteria.az: return basename(a.path.toLowerCase()).compareTo(basename(b.path.toLowerCase()));
          case SortCriteria.za: return -(basename(a.path.toLowerCase()).compareTo(basename(b.path.toLowerCase())));
          case SortCriteria.LastModifiedUp: return a.lastModifiedSync().compareTo(b.lastModifiedSync());
          case SortCriteria.LastModifiedDown: return -(a.lastModifiedSync().compareTo(b.lastModifiedSync()));
          case SortCriteria.Extension_az: return extension(a.path).substring(1).compareTo(extension(b.path).substring(1));
          case SortCriteria.Extension_za : return -(extension(a.path).substring(1).compareTo(extension(b.path).substring(1)));
          case SortCriteria.SizeAscending: return a.lengthSync().compareTo(b.lengthSync());
          case SortCriteria.SizeDescending: return -(a.lengthSync().compareTo(b.lengthSync()));
        }
      } else if(a is Directory && b is Directory){
        switch(criteria){
          case SortCriteria.az: return basename(a.path.toLowerCase()).compareTo(basename(b.path.toLowerCase()));
          case SortCriteria.za: return -(basename(a.path.toLowerCase()).compareTo(basename(b.path.toLowerCase())));
          case SortCriteria.LastModifiedUp: return _lastModifiedDirectory(a).compareTo(_lastModifiedDirectory(b));
          case SortCriteria.LastModifiedDown: return -(_lastModifiedDirectory(a).compareTo(_lastModifiedDirectory(b)));
          case SortCriteria.Extension_az:
          case SortCriteria.Extension_za: return 0;
          case SortCriteria.SizeAscending: return _sizeOfContents(directory: a).compareTo(_sizeOfContents(directory: b));
          case SortCriteria.SizeDescending: return -(_sizeOfContents(directory: a).compareTo(_sizeOfContents(directory: b)));
        }
      }
      return 0;
    });
    return returnVal;
  }


  static Future<List<FileSystemEntity>> _filesByCategory({Category category, List<Directory> storageMedia}) async{
    List<FileSystemEntity> allFiles = <FileSystemEntity>[];
    List<FileSystemEntity> files = <FileSystemEntity>[];
    for(Directory dir in storageMedia){
      String newPath = dir.path;
      print('PATH: $newPath');
      dir = Directory(newPath);
      category != Category.Download ? allFiles.addAll(dir.listSync(followLinks: false, recursive: true)) : allFiles = null;
    }
    switch(category){
      case Category.Download: {
        for(Directory dir in storageMedia){
          String downloadPath = dir.path + '/Download';
          Directory downloads = Directory(downloadPath);
          files.addAll(downloads.listSync(followLinks: false,));
        }
        return files;
      }
      case Category.Apk:{
        String mimeID = 'vnd.android.package-archive';
        files = allFiles.where((entity) => ((mime(entity.path) ?? '').split('/').length > 1 ? (mime(entity.path) ?? '').split('/')[1] : '') == mimeID).toList();
        return files;
      }
      case Category.Archive:{
        List mimeID = <String>['zip', 'x-gzip', 'x-xz', 'x-rar-compressed'];
        files = allFiles.where((entity){
          String entityType = (mime(entity.path) ?? '').split('/').length > 1 ? (mime(entity.path) ?? '').split('/')[1] : '';
          for(String type in mimeID){
            if(type == entityType){
              return true;
            }else return false;
          }return false;
        }).toList();
        return files;
      }
      case Category.Document:{
        List<String> mimeID = <String>['pdf', 'csv', 'document', 'presentation', 'sheet', 'text', 'plain'];
        files = allFiles.where((entity){
          String entityType = (mime(entity.path) ?? '').split('/').length > 1 ? (mime(entity.path) ?? '').split('/')[1] : '';
          for(String type in mimeID){
            if(entityType.contains(type) && entity is File){
              return true;
            }
          }return false;
        }).toList();
        return files;
      }
      case Category.Image:{
        String mimeID = 'image';
        files = allFiles.where((entity){
          String entityType = (mime(entity.path) ?? '').split('/')[0];
          return entityType == mimeID ? true : false;
        }).toList();
        return files;
      }
      case Category.Music:{
        String mimeID = 'audio';
        files = allFiles.where((entity){
          String entityType = (mime(entity.path) ?? '').split('/')[0];
          return entityType == mimeID ? true : false;
        }).toList();
        return files;
      }
      case Category.Video: {
        String mimeID = 'video';
        files = allFiles.where((entity){
          String entityType = (mime(entity.path) ?? '').split('/')[0];
          return entityType == mimeID ? true : false;
        }).toList();
        return files;
      }
      default: break;
    }
    return null;
  }

  static Map<String, int> _directoryContentsStats(Directory dir){
    int files = 0;
    int directories = 0;
    List<FileSystemEntity> contents = dir.listSync(followLinks: false);
    for(FileSystemEntity entity in contents){
      if(entity is File){
        files++;
      }else if(entity is Directory){
        directories++;
      }
    }
    return {'Files': files, 'Directories': directories};
  }

  static int _sizeOfContents({Directory directory, List<FileSystemEntity> list}){
    List<FileSystemEntity> contents = list == null ? directory.listSync(followLinks: false) : list;
    int size = 0;
    for(FileSystemEntity entity in contents){
      if(entity is File){
        size += entity.lengthSync();
      } else if(entity is Directory){
        size += _sizeOfContents(directory: entity);
      }
    }
    return size;
  }

  static DateTime _lastModifiedDirectory(Directory dir){
//    List<File> contents = dir.listSync(recursive: true, followLinks: false).where((entity) => entity is File);
//    DateTime lastMod = contents[0].lastModifiedSync(), start = DateTime.now();
//    Duration difference = contents[0].lastModifiedSync().difference(start);
//    for(File entity in contents){
//      assert(entity is File);
//      Duration currentDifference = entity.lastModifiedSync().difference(start);
//      if(currentDifference < difference){
//        difference = currentDifference;
//        lastMod = entity.lastModifiedSync();
//      }
//    }
    return DateTime.now();
  }

  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return "0.0 KB";
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }

  static String getClippedString({String initTitle, int stringLimit}) {
    stringLimit = stringLimit ?? 15;
    final String ellipsis = '...';
    String finalTitle = '';
    if (initTitle.length > stringLimit) {
      finalTitle =
          initTitle.substring(0, (stringLimit - ellipsis.length)) + ellipsis;
      return finalTitle;
    } else
      return initTitle;
  }

  static String formatTime({DateTime lastModifiedTime}){
    final timeNow = DateTime.now();
    var difference = timeNow.difference(lastModifiedTime);
    if((difference.inDays.toInt()) >= 365){
      return (difference.inDays/365).round().toString() + ' Years, ' + ((difference.inDays%365)/30).round().toString() + ' Months Ago';
    }else if(difference.inDays.toInt() >= 30){
      return (difference.inDays/30).round().toString() + ' Months, ' + (difference.inDays%30).round().toString() + ' Days Ago';
    }else if(difference.inDays.toInt() >= 1){
      return difference.inDays.round().toString() + ' days ago';
    } else if(difference.inHours.toInt() >= 1){
      return difference.inHours.round().toString() + ' hours ago';
    }else if(difference.inMinutes.toInt() >= 1){
      return difference.inMinutes.round().toString() + ' minutes ago';
    }else return difference.inSeconds.round().toString() + ' seconds ago';
  }

  void dispose(){
    _isolate.kill();
  }
}