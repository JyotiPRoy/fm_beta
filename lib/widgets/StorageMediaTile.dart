import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fm_beta/bloc/BlocProvider.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';
import 'package:fm_beta/model/StorageMedium.dart';
import 'package:fm_beta/pages/DirectoryViewPage.dart';
import 'package:fm_beta/utils/FileUtils.dart';
import 'package:fm_beta/widgets/DonutChartWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StorageMediaTile extends StatefulWidget {
  final StorageMedium storageMedium;
  final FileSystemBloc bloc;
  final ScrollController scrollController;
  final AnimationController menuController;

  StorageMediaTile(
      {Key key,
      this.bloc,
      this.storageMedium,
      this.scrollController,
      this.menuController})
      : super(key: key);

  @override
  _StorageMediaTileState createState() => _StorageMediaTileState();
}

class _StorageMediaTileState extends State<StorageMediaTile> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context).bloc;
    final mtBloc = BlocProvider.of(context).mtBloc;
    final inFocusColor = Color.fromRGBO(61, 116, 221, 1);
    final outOfFocusColor = Color.fromRGBO(242, 245, 248, 1);
    Color color = inFocusColor;
    final totalSpace = FileUtils.formatBytes(widget.storageMedium.getTotalSpace(), 2);
    final usedSpace = FileUtils.formatBytes((widget.storageMedium.getTotalSpace() - widget.storageMedium.getFreeSpace()), 2);
    final double percentUsage = ((widget.storageMedium.getTotalSpace() - widget.storageMedium.getFreeSpace()) / widget.storageMedium.getTotalSpace()) * 100;
    return LayoutBuilder(
      builder: (context, constraints) {
        // final height = MediaQuery.of(context).size.height;
        // final width = MediaQuery.of(context).size.width;
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        bool isScaledDown =
            constraints.maxWidth <= (MediaQuery.of(context).size.width * 0.62);

        return Center(
          child: GestureDetector(
            onTap: () {
              if (!widget.menuController.isDismissed) {
                widget.menuController.reverse();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DirectoryViewPage(
                      bloc: bloc,
                      parentMedium: widget.storageMedium,
                      mtID: Key('0000'),
                    ),
                  ),
                );
              }
            },
            onLongPress: () {
              HapticFeedback.vibrate();
              int newID = mtBloc.generateTabID();
              dev.log('NEW ID $newID');
              var newPage = DirectoryViewPage(
                bloc: bloc,
                parentMedium: widget.storageMedium,
                mtID: Key(newID.toString()),
              );
              mtBloc.addTab(newID, newPage);
            },
            child: Container(
              margin: EdgeInsets.only(
                  right: width * 0.038,
                  top: height * 0.005,
                  bottom: height * 0.03),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(61, 116, 221, 0.5),
                      blurRadius: 12,
                      offset: Offset(6, 6),
                    )
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(0, height * 0.1, 0, height * 0.295),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: isScaledDown ? height * 0.2 : height * 0.2,
                          width: isScaledDown ? width * 0.12 : width * 0.13,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(38, 90, 191, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Center(
                              child: Icon(
                            FontAwesomeIcons.mobile,
                            color: Colors.white,
                            size: isScaledDown ? 18 : 20,
                          )),
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.storageMedium.name}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isScaledDown ? 15 : 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'),
                            ),
                            // SizedBox(
                            //   height: 0,
                            // ),
                            Text(
                              '${widget.storageMedium.path}',
                              style: TextStyle(
                                  color: Colors.grey[200],
                                  fontSize: isScaledDown ? 11 : 14,
                                  fontFamily: 'Montserrat'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: height * 0.017,
                        left: width * 0.1,
                        right: width * 0.095),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${percentUsage.toStringAsFixed(2)} %',
                          style: TextStyle(
                              color: Colors.grey[200],
                              fontSize: isScaledDown ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat'),
                        ),
                        SizedBox(
                          height: height * 0.004,
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            child: LinearProgressIndicator(
                              value: percentUsage / 100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromRGBO(255, 247, 43, 1)),
                              backgroundColor:
                                  Color.fromRGBO(251, 251, 251, 0.56),
                            )),
                        SizedBox(
                          height: height * 0.004,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$usedSpace',
                              style: TextStyle(
                                  color: Colors.grey[200],
                                  fontSize: isScaledDown ? 10 : 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'),
                            ),
                            Text(
                              '$totalSpace',
                              style: TextStyle(
                                  color: Colors.grey[200],
                                  fontSize: isScaledDown ? 10 : 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
