import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/pages/DirectoryViewPage.dart';
import 'package:fm_beta/utils/IntentHandler.dart';
import 'package:fm_beta/widgets/FMDialogWidget.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:path_provider/path_provider.dart';

class FileActions {
  FileUtils _fileUtils;
  StreamController<double> progressController = StreamController<double>.broadcast();
  StreamController<SelectionMode> selectionModeController;
  FileSystemBloc bloc;
  String _targetPath;
  bool _cancelCopy = false;
  Directory cacheDirectory;


  FileActions({this.bloc, this.selectionModeController}){
    initFileUtils();
    bloc.currentPath.listen((path) {
      _targetPath = path;
    });
  }

  Stream<double> get progress => progressController.stream;

  Future<void> initFileUtils() async{
    _fileUtils = FileUtils();
    await _fileUtils.isolateReady;
    cacheDirectory = await getTemporaryDirectory();
  }

  StreamController<double> _createProgressStream(){
    return StreamController<double>();
  }

  Future<void> share({List<FileSystemEntity> entitiesToShare}) async{
    dynamic data;
    String mimeType;
    if(entitiesToShare.length == 1){
      FileSystemEntity entity = entitiesToShare.first;
      if(entity is File){
        data = entity.path;
        mimeType = mime(entity.path);
      }else if(entity is Directory){
        List<FileSystemEntity> contents = entity.listSync(recursive: true);
        List<String> paths = <String>[];
        for(FileSystemEntity fileEntity in contents){
          if(fileEntity is File){
            paths.add(fileEntity.path);
          }
        }
        data = paths;
        mimeType = '*/*';
      }
    }else{
      List<String> paths = <String>[];
      for(FileSystemEntity entity in entitiesToShare){
        paths.add(entity.path);
      }
      data = paths;
      mimeType = '*/*';
    }
    IntentHandler share = IntentHandler(
        intentType: IntentType.Share,
        data: data,
        mimeType: mimeType ?? '*/*'
    );
    share.launch();
  }

  void copy({List<FileSystemEntity> entityList, Directory directory, BuildContext context}) async{
    print('PUBLIC FUNCTION: COPY START!');
    print('TARGET PATH: $_targetPath');
    var copySubscription = _copyWithProgress(targetPath: _targetPath ,entityList: entityList, directory: directory, context: context);
    await for(double progress in copySubscription){
      progressController.add(progress);
    }
    selectionModeController.add(SelectionMode.OFF);
  }

  void cancel(){
    _cancelCopy = true;
   selectionModeController.add(SelectionMode.OFF);
  }

  Stream<double> _copyWithProgress({String targetPath ,List<FileSystemEntity> entityList, Directory directory, BuildContext context}) async* {
    int totalBytesWritten = 0 ,totalSize, index = 0;
    entityList = entityList ?? directory.listSync();
    totalSize = await _fileUtils.sizeofContents(list: entityList);
    for(FileSystemEntity entity in entityList){
      print('COPY START!');
      int bytesWritten = 0;
      if(entity is File){
        int fileSize = await entity.length();
        File targetFile;
        if(File(targetPath + '/${basename(entity.path)}').existsSync()){
          targetFile = await _alertFileExists(targetPath: targetPath, entity: entity, context: context);
        }else targetFile = File(targetPath + '/${basename(entity.path)}');
        await targetFile.create();
        Stream readStream = entity.openRead();
        await for(List<int> bytes in readStream){
          if(!_cancelCopy){
            print('BYTES WRITTEN: ${FileUtils.formatBytes(bytesWritten, 2)}');
            await targetFile.writeAsBytes(bytes, mode: FileMode.writeOnlyAppend, flush: true);
            bytesWritten += bytes.length;
            totalBytesWritten += bytes.length;
            if(directory == null){
              yield totalBytesWritten/totalSize;
            }else yield bytes.length.toDouble();
            if(bytesWritten == fileSize){
              bloc.folderPath.add(_targetPath);
              print('COPY COMPLETE!!!');
            }
          }else break;
        }
      }else if(entity is Directory){
        if(!_cancelCopy){
          Directory targetDir = Directory(targetPath + '/${basename(entity.path)}');
          await targetDir.create();
          // bloc.folderPath.add(_targetPath); /// TODO: FIX refreshing folder contents after folder is added & removing it from view when deleted while cancelling copy
          String finalTargetPath = targetPath + '/${basename(targetDir.path)}';
          var copy = _copyWithProgress(targetPath: finalTargetPath ,directory: entity);
          await for(double bytes in copy){
            bytesWritten += bytes.toInt();
            totalBytesWritten += bytes.toInt();
            print('TOTAL_BYTES: ${FileUtils.formatBytes(totalBytesWritten, 2)}, TOTAL_SIZE: ${FileUtils.formatBytes(totalSize, 2)}');
            yield totalBytesWritten/totalSize;
          }
        }else break;
      }
      if(_cancelCopy){
        for(int i = 0; i <= index; i++){
          print('${entityList[i].path}');
          FileSystemEntity targetEntity = entityList[i] is File
                                          ? File(targetPath + '/${basename(entityList[i].path)}')
                                          : Directory(targetPath + '/${basename(entityList[i].path)}');
          targetEntity.deleteSync(recursive: true);
        }
        break;
      }
      index++;
    }
    // bloc.folderPath.add(_targetPath); /// TODO: FIX refreshing folder contents after folder is added & removing it from view when deleted while cancelling copy
    // _targetPath = null;
  }

  Future<File> _alertFileExists({String targetPath, FileSystemEntity entity, BuildContext context}) async{
    bool overwrite = false;
    FMDialog alertDuplicate = FMDialog(
      dialogType: DialogType.Confirmation,
      title: 'Duplicate FileSystemEntity',
      content: 'A File or Folder with that name already exists! Overwrite?',
      buttonLabels: ['Overwrite', 'Keep Both'],
      okTapped: (){
        overwrite = false;
        Navigator.pop(context);
      },
      cancelTapped: (){
        File(targetPath + '/${basename(entity.path)}').deleteSync();
        overwrite = true;
        Navigator.pop(context);
      },
    );
    await showDialog<FMDialog>(
        context: context,
        builder: (context){
          return alertDuplicate;
        },
        barrierColor: Colors.grey[900].withOpacity(0.5)
    );
    if(overwrite){
      return File(targetPath + '/${basename(entity.path)}');
    }else{
      String fileNameWithExtension = basename(entity.path);
      return File(targetPath + '/${fileNameWithExtension.split('.')[0]}-Copy.${fileNameWithExtension.split('.')[1]}');
    }
  }

  Future<void> delete({BuildContext context}) async{

  }

}