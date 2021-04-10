import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fm_beta/model/StorageMedium.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fm_beta/utils/FileUtils.dart';

class FileSystemBloc {
  final _fileSystemSubject = BehaviorSubject<UnmodifiableListView<FileSystemEntity>>();
  final _storageMediaSubject = BehaviorSubject<UnmodifiableListView<StorageMedium>>();
  final _folderPathController = StreamController<String>.broadcast();
  final _sortCriteriaController = StreamController<MapEntry<String, SortCriteria>>();
  final _filesByCategoryController = StreamController<List<FileSystemEntity>>.broadcast();
  final _categoryInputController = StreamController<Category>();
  final _categoryStorageUsageIndicatorController = StreamController<MapEntry<int,int>>.broadcast();
  final _allFilesForSearchController = StreamController<UnmodifiableListView<FileSystemEntity>>.broadcast();
  final _splashScreenController = StreamController<bool>();
  FileUtils _fileUtils;

  var _folderContents = <FileSystemEntity>[];
  var _storageMedia = <StorageMedium>[];
  Map<String, SortCriteria> _sortCriteriaPrefs = <String, SortCriteria>{};
  Map<Category,List<FileSystemEntity>> _filesByCategoryMap = <Category,List<FileSystemEntity>>{};
  Category _currentCategory;
  List<FileSystemEntity> allFiles = <FileSystemEntity>[];

  FileSystemBloc() {
    _initIndexForSearch();
    initSortCriteriaPrefs();
    _initFileUtil();
    _sortCriteriaController.stream.listen((MapEntry<String, SortCriteria> mapEntry) {
      updateSortCriteria(mapEntry);
      _sortCriteriaController.add(mapEntry);
    });
    _folderPathController.stream.listen((String path) async{
      _folderContents.clear();
      await updateFolderContents(Directory(path));
      _fileSystemSubject.add(UnmodifiableListView(_folderContents));
    });
    _categoryInputController.stream.listen((category) async{
      _currentCategory = category;
      if(!_filesByCategoryMap.containsKey(category)){
        var files = await _fileUtils.sortFolderContents(list: await _fileUtils.getFilesByCategory(
            category: category,
            storageMedia: _storageMedia.map((media) => Directory(media.path)).toList()),
            criteria: SortCriteria.SizeDescending
        );
        _filesByCategoryMap[category] = files;
        _filesByCategoryController.add(files);
      }else _filesByCategoryController.add(_filesByCategoryMap[category]);
    });
    _filesByCategoryController.stream.listen((list) async{
      MapEntry<int,int> categoryStorageUsage;
      int totalSize = 0,
          categoryFilesSize = await _fileUtils.sizeofContents(list: list);
      for(StorageMedium medium in _storageMedia){
        totalSize += medium.getTotalSpace();
      }
      categoryStorageUsage = MapEntry<int,int>(totalSize,categoryFilesSize);
      _categoryStorageUsageIndicatorController.add(categoryStorageUsage);
    });
  }

  Stream<UnmodifiableListView<FileSystemEntity>> get contents => _fileSystemSubject.asBroadcastStream();
//  Sink<UnmodifiableListView<FileSystemEntity>> get addContents => _fileSystemSubject.sink;
  Stream<UnmodifiableListView<StorageMedium>> get storageMediaList => _storageMediaSubject.stream;
  Sink<String> get folderPath => _folderPathController.sink;
  Stream<String> get currentPath => _folderPathController.stream;
  Sink<MapEntry<String, SortCriteria>> get changeSortCriteria => _sortCriteriaController.sink;
  Stream<MapEntry<String, SortCriteria>> get currentSortCriteria => _sortCriteriaController.stream;
  Stream<List<FileSystemEntity>> get filesByCategory => _filesByCategoryController.stream;
  Sink<Category> get categoryInput => _categoryInputController.sink;
  Stream<MapEntry<int,int>> get categoryStorageUsageIndicator => _categoryStorageUsageIndicatorController.stream;
  Stream<UnmodifiableListView<FileSystemEntity>> get allFileEntities => _allFilesForSearchController.stream;
  Stream<bool> get exitSplashScreen => _splashScreenController.stream;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _sortCriteriaPrefsJson async {
    String path = await _localPath;
    File jsonFile = File('$path/SortCriteriaPrefs.json');
    return jsonFile;
  }

  Future<void> _initFileUtil() async{
    _fileUtils = FileUtils();
    await _fileUtils.isolateReady;
  }

  Future<void> _initIndexForSearch() async{
    await _initStorageMedia();
    for(StorageMedium medium in _storageMedia){
      var contents = Directory(medium.path).list(recursive: true);
      await for(FileSystemEntity entity in contents){
        allFiles.add(entity);
        print("ENTITY: ${entity.path}");
      }
    }
    _allFilesForSearchController.add(UnmodifiableListView(allFiles));
    _splashScreenController.add(true); // True exits from the splashScreen
  }

  /// In Future Cloud Drive initializations can also be done here
  Future<void> _initStorageMedia() async {
    MethodChannel platform = MethodChannel('com.example.fm_beta');
    List<FileSystemEntity> dirs = await getExternalStorageDirectories();
    String path;
    int totalSpace, freeSpace;
    for (int i = 0; i < dirs.length; i++) {
      switch (i) {
        case 0:
          {
            path = dirs[0].path.split('/Android')[0];
            print('${dirs[0].path}');
            totalSpace = await platform.invokeMethod('getSDTotalSpace');
            freeSpace = await platform.invokeMethod('getSDFreeSpace');
            StorageMedium sd = StorageMedium(
                path: path, name: 'Internal Storage', totalSpace: totalSpace, freeSpace: freeSpace);
            _storageMedia.add(sd);
            break;
          }
        case 1:
          {
            path = dirs[1].path.split('/Android')[0];
            totalSpace = await platform.invokeMethod('getExternalSDTotalSpace');
            freeSpace = await platform.invokeMethod('getExternalSDFreeSpace');
            StorageMedium extSD = StorageMedium(
                path: path, name: 'External Storage', totalSpace: totalSpace, freeSpace: freeSpace);
            _storageMedia.add(extSD);
            break;
          }
      }
    }
    _storageMediaSubject.add(UnmodifiableListView(_storageMedia));
  }

  Future<void> updateSortCriteria(
      MapEntry<String, SortCriteria> mapEntry) async {
    String path = mapEntry.key;
    SortCriteria criteria = mapEntry.value;
    if (criteria == SortCriteria.az) {
      _sortCriteriaPrefs.remove(path);
    } else
      _sortCriteriaPrefs[path] = criteria;
    Map<String, String> criteriaToString = _sortCriteriaPrefs.map((k, v) {
      return MapEntry<String, String>(k, v.toString());
    });
    String jsonStr = jsonEncode(criteriaToString);
    File jsonFile = await _sortCriteriaPrefsJson;
    jsonFile.writeAsString(jsonStr);
  }

  Future<void> initSortCriteriaPrefs() async {
    final jsonFile = await _sortCriteriaPrefsJson;
    String jsonStr = await jsonFile.readAsString();
    print('$jsonStr');
    Map<String, dynamic> stringCriteria = jsonDecode(jsonStr);
    _sortCriteriaPrefs = stringCriteria.map((k, v) {
      String criteriaStr = v;
      SortCriteria criteria;
      for (SortCriteria element in SortCriteria.values) {
        if (element.toString() == criteriaStr) {
          criteria = element;
        }
      }
      return MapEntry<String, SortCriteria>(k, criteria);
    });
  }

  Future<void> updateFolderContents(Directory dir) async{
    String path = dir.path;
    SortCriteria criteria;
    if (_sortCriteriaPrefs.containsKey(path)) {
      criteria = _sortCriteriaPrefs[path];
    } else criteria = _sortCriteriaPrefs['Global'];
    _folderContents = await _fileUtils.sortFolderContents(list: dir.listSync().where((entity) => !basename(entity.path).startsWith('.')).toList(), criteria: criteria);
  }
}
