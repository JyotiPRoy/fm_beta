import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/pages/DirectoryViewPage.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:fm_beta/utils/ThumbnailProvider.dart';
import 'package:fm_beta/widgets/AnimatedBottomBar.dart';
import 'package:fm_beta/widgets/GridTileView.dart';

class CategoriesPage extends StatefulWidget {
  final Category category;
  final FileSystemBloc bloc;

  CategoriesPage({
    @required this.category,
    @required this.bloc
  }) : assert(category != null), assert(bloc != null);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with TickerProviderStateMixin{
  FileSystemBloc bloc;
  ThumbnailProvider thumbnailProvider;
  Map<Key,FileSystemEntity> _selectedItems = Map<Key,FileSystemEntity>();
  StreamController<SelectionMode> selectionModeController = StreamController<SelectionMode>();
  SelectionMode selectionMode = SelectionMode.OFF;
  Color labelColor = Colors.green;
  Map<Category,String> _bannerContents = <Category,String>{
    Category.Document : 'assets/icons/google-docs.svg\nDocuments\nBrowse and Organize all your work related stuff',
    Category.Video : 'assets/icons/video.svg\nVideos\nMovies, music videos, or how about a walk down the memory lane?',
    Category.Music : "assets/icons/music-category.svg\nMusic\nWho doesn't love some music?",
    Category.Image : 'assets/icons/gallery.svg\nImages\nExplore your memorable moments',
    Category.Archive : 'assets/icons/archive-category.svg\nArchives\nBrowse all your compressed files',
    Category.Apk : 'assets/icons/app-category.svg\nApplications\nAll your non-installed apk files can be found here'
  };
  List<String> bannerBuilder = <String>[];
  AnimationController controller1, controller2;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    bloc.categoryInput.add(widget.category);
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
    initBannerBuilder();
  }

  @override
  void dispose(){
    thumbnailProvider.dispose();
    super.dispose();
  }

  void initBannerBuilder(){
    String bannerString = _bannerContents[widget.category];
    bannerBuilder = bannerString.split('\n');
  }

  Sink<SelectionMode> get selectionModeSetter => selectionModeController.sink;

  Future<void> initThumbnails() async{
    thumbnailProvider = ThumbnailProvider();
    // await thumbnailProvider.isolateReady;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async{
        if(selectionMode == SelectionMode.ON){
          selectionMode = SelectionMode.OFF;
          setState(() {
            _selectedItems.clear();
          });
          return false;
        }else{
//          dispose();
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(0, 1, 25, 1),
            leading: IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: height > 700
                          ? height * 0.020
                          : height * 0.015),
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.012),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius:
                    BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.012,
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  color: Color.fromRGBO(0, 1, 25, 1),
                  height: height * 0.27,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05,),
                        child: Container(
//                          color: Colors.red,
                          padding:
                          EdgeInsets.symmetric(vertical: height * 0.01),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    height: height * 0.05,
                                    width: height * 0.05,
                                    child: SvgPicture.asset(
                                        bannerBuilder[0]),
                                  ),
                                  SizedBox(width: 4,),
                                  Text(
                                    bannerBuilder[1],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * 0.008,
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    bannerBuilder[2],
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontStyle: FontStyle.italic),
                                  )
                              ),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              StreamBuilder<MapEntry<int,int>>(
                                stream: bloc.categoryStorageUsageIndicator,
                                  builder: (context,snapshot){
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(text: 'Used:   ', style: TextStyle(color: Colors.white, fontSize: 12)),
                                                TextSpan(
                                                    text: snapshot.hasData
                                                        ? ((snapshot.data.value/snapshot.data.key) * 100).toStringAsFixed(2) + '%'
                                                        : (snapshot.connectionState == ConnectionState.waiting ? '-%' : 'N/A'),
                                                    style: TextStyle(color: Colors.white, fontSize: 26)
                                                ),
                                              ]
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.004,
                                        ),
                                        AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                color: labelColor,
                                                borderRadius: BorderRadius.all(Radius.circular(4))
                                            ),
                                            child: Text(
                                                snapshot.hasData
                                                    ? '${FileUtils.formatBytes(snapshot.data.value,1)} / ${FileUtils.formatBytes(snapshot.data.key,1)}'
                                                    : (snapshot.connectionState == ConnectionState.waiting ? 'Loading... ' : 'Failed To load'),
                                                style: TextStyle(color: Colors.white, fontSize: 14)
                                            )
                                        ),
                                        SizedBox(
                                          height: height * 0.01,
                                        ),
                                        Container(
                                          width: width,
                                          child: Theme(
                                            data: Theme.of(context).copyWith(accentColor: Colors.green),
                                            child: snapshot.hasData
                                                ? LinearProgressIndicator(
                                              value: snapshot.data.value/snapshot.data.key,
                                              backgroundColor: labelColor.withOpacity(0.4),
                                            )
                                                : (snapshot.connectionState == ConnectionState.waiting
                                                ? LinearProgressIndicator(
                                              backgroundColor: labelColor.withOpacity(0.4),
                                            )
                                                : LinearProgressIndicator(
                                              value: 0,
                                              backgroundColor: Colors.red,
                                            )
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.73,
                minChildSize:  0.73,
                maxChildSize: 0.99,
                builder: (context, scrollController){
                  initThumbnails();
                  _scrollController = scrollController;
                  thumbnailProvider.setScrollController(scrollController);
                  return Container(
                    padding: EdgeInsets.only(top: 15, left: 5, right: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                    ),
                    child: StreamBuilder<List<FileSystemEntity>>(
                        stream: bloc.filesByCategory,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            return GridView.builder(
                              controller: scrollController,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.80,
                                  mainAxisSpacing: 5
                              ),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index){
                                FileSystemEntity entity = snapshot.data[index];
                                return GridTileView(
                                  key: Key('${entity.path}'),
                                  entity: entity,
                                  bloc: bloc,
                                  selectedItems: _selectedItems,
                                  selectionModeSetter: selectionModeController,
                                  selectionMode: selectionMode,
                                  thumbnailProvider: thumbnailProvider,
                                );
                              },
                            );
                          }else if(snapshot.connectionState == ConnectionState.waiting){
                            return Center(child: CircularProgressIndicator());
                          }else return Text('Loading Failed');
                        }
                    ),
                  );
                },
              ),
              AnimatedBottomBar(
                controller1: controller1,
                controller2: controller2,
                selectionModeController: selectionModeController,
                selectionMode: selectionMode,
                selectedItems: _selectedItems,
              )
            ],
          ),
        ),
      ),
    );
  }
}
