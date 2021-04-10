import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/model/StorageMedium.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';

class PathNavigator extends StatefulWidget {
  final String initPath;
  final FileSystemBloc bloc;

  PathNavigator({Key key, @required this.initPath, @required this.bloc})
      : super(key: key);

  @override
  _PathNavigatorState createState() => _PathNavigatorState();
}

class _PathNavigatorState extends State<PathNavigator> {
  List<FolderNode> _folderNodes = <FolderNode>[];
  String _currentPath;
  ScrollController _scrollController;
  FolderNode separator = FolderNode(
    path: '/',
    initIcon: Icon(
      CupertinoIcons.forward,
      color: Colors.white,
    ),
  );
  FileSystemBloc bloc;
  Map _initIcons = <String, Icon>{
    'Internal Storage': Icon(
      FontAwesomeIcons.mobile,
      color: Colors.white,
      size: 20,
    ),
    'External Storage': Icon(
      FontAwesomeIcons.sdCard,
      color: Colors.white,
    )
  };

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    _currentPath = widget.initPath;
    _setInitIcon();
    _scrollController = ScrollController();
    bloc.currentPath.listen((newPath) {
      if (newPath != _currentPath) {
        updatePath(newPath: newPath);
      }
    });
  }

  void _setInitIcon() {
    bloc.storageMediaList.listen((storageMedia) {
      for (StorageMedium medium in storageMedia) {
        if (_currentPath == medium.getPath()) {
          if (this.mounted) {
            setState(() {
              _folderNodes.add(
                FolderNode(
                  path: medium.getPath(),
                  initIcon: _initIcons[medium.name],
                ),
              );
              _folderNodes.add(separator);
            });
          }
        }
      }
    });
  }

  void updatePath({String newPath}) async {
    if (this.mounted) {
      if (newPath.length > _currentPath.length) {
        setState(() {
          _currentPath = newPath;
          if (_folderNodes.length != 2) {
            _folderNodes.add(separator);
          }
          _folderNodes.add(FolderNode(
            path: newPath,
          ));

          ///Adding some delay to let flutter update the list. TODO: Need to find a better solution
          Future.delayed(Duration(milliseconds: 100), () {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300));
          });
        });
      } else {
        int index;
        _folderNodes.forEach((node) {
          if (node.path == newPath) {
            index = _folderNodes.indexOf(node);
          }
        });
        setState(() {
          _currentPath = newPath;
          for (int i = _folderNodes.length - 1;
              i > (newPath == widget.initPath ? index + 1 : index);
              i--) {
            _folderNodes.removeAt(i);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: _folderNodes.map((node) {
          if (node.path != '/' && node.initIcon == null) {
            return InkWell(
              onTap: () {
                bloc.folderPath.add(node.path);
              },
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: node,
            );
          } else return node;
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _folderNodes.clear();
    super.dispose();
  }
}

class FolderNode extends StatelessWidget {
  final String path;
  final Icon initIcon;

  FolderNode({@required this.path, this.initIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
      child: initIcon == null
          ? Text(
              '${basename(path)}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            )
          : initIcon,
    );
  }
}
