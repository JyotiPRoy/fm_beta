import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum DialogType { Alert, Confirmation, Input}

TextStyle titleStyle = TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);
TextStyle contentStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
);

class FMDialog extends StatelessWidget {
  final DialogType dialogType;
  final String title;
  final dynamic content;
  final List<String> buttonLabels;
  final TextEditingController editingController;
  final GestureTapCallback okTapped;
  final GestureTapCallback cancelTapped;

  FMDialog({
    @required this.dialogType,
    this.title,
    this.content,
    this.buttonLabels,
    this.editingController,
    this.okTapped,
    this.cancelTapped
  })  : assert(dialogType != null),
        assert(editingController == null || dialogType == DialogType.Input),
        assert(cancelTapped == null || dialogType != DialogType.Alert);

  @override
  Widget build(BuildContext context) {
    switch (dialogType) {
      case DialogType.Alert:
        return _GenericAlertDialog(
          title: title,
          content: content,
          okTapped: okTapped,
          buttonLabels: buttonLabels,
        );
      case DialogType.Confirmation:
        return _GenericConfirmationDialog(
          title: this.title,
          content: this.content,
          okTapped: okTapped,
          cancelTapped: cancelTapped,
          buttonLabels: buttonLabels,
        );
      case DialogType.Input :
        return _GenericInputDialog(
          title: this.title,
          content: content,
          editingController: editingController,
          okTapped: okTapped,
          cancelTapped: cancelTapped,
          buttonLabels: buttonLabels,
        );
      default:
        break;
    }
    return Center(
      child: Text(
        'Invalid DialogType!',
        style: contentStyle,
      ),
    );
  }
}

class _GenericAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final GestureTapCallback okTapped;
  final List<String> buttonLabels;

  _GenericAlertDialog({
    this.title,
    this.content,
    this.okTapped,
    this.buttonLabels
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: height * 0.362,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  height: height * 0.275,
                  width: width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey[900].withOpacity(0.6),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: height * 0.015 + (height * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
//                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                width: width * 0.67,
                                child: Text(
                                  '$title',
                                  style: titleStyle,
                                  textAlign: TextAlign.center,
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                width: width * 0.7,
                                child: Text(
                                  '$content',
                                  style: contentStyle,
                                  textAlign: TextAlign.center,
                                ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: _DialogActions(
                          dialogType: DialogType.Alert,
                          okTapped: okTapped,
                          buttonLabels: buttonLabels,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: (height * 0.362) - (height * 0.05),
          child: _CircularDialogHeader(
            dialogType: DialogType.Alert,
          ),
        )
      ],
    );
  }
}

class _GenericConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final GestureTapCallback okTapped;
  final GestureTapCallback cancelTapped;
  final List<String> buttonLabels;

  _GenericConfirmationDialog({
    this.title,
    this.content,
    this.okTapped,
    this.cancelTapped,
    this.buttonLabels
  }) : assert(okTapped != null && cancelTapped != null);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: height * 0.362,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  height: height * 0.275,
                  width: width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey[900].withOpacity(0.6),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: height * 0.015 + (height * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
//                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                width: width * 0.67,
                                child: Text(
                                  '$title',
                                  style: titleStyle,
                                  textAlign: TextAlign.center,
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                width: width * 0.7,
                                child: Text(
                                  '$content',
                                  style: contentStyle,
                                  textAlign: TextAlign.center,
                                ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: _DialogActions(
                          dialogType: DialogType.Confirmation,
                          okTapped: okTapped,
                          cancelTapped: cancelTapped,
                          buttonLabels: buttonLabels,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: (height * 0.362) - (height * 0.05),
          child: _CircularDialogHeader(
            dialogType: DialogType.Confirmation,
          ),
        )
      ],
    );
  }
}

class _GenericInputDialog extends StatefulWidget {
  final String title;
  final Stream<String> content;
  final GestureTapCallback okTapped;
  final GestureTapCallback cancelTapped;
  final TextEditingController editingController;
  final List<String> buttonLabels;

  _GenericInputDialog({
    this.title,
    this.content,
    this.okTapped,
    this.cancelTapped,
    this.editingController,
    this.buttonLabels
  }) : assert(okTapped != null && cancelTapped != null);

  @override
  __GenericInputDialogState createState() => __GenericInputDialogState();
}

class __GenericInputDialogState extends State<_GenericInputDialog> {
  String content = '';
  TextStyle thisContentStyle = TextStyle(color: Colors.white, fontSize: 12);

  @override
  void initState() {
    super.initState();
    widget.content.listen((newContent) {
      setState(() {
        content = newContent ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: height * 0.362,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  height: height * 0.275,
                  width: width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey[900].withOpacity(0.6),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: height * 0.03,
                        child: Container(
                          width: width * 0.75,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  width: width * 0.67,
                                  child: Text(
                                    '${widget.title}',
                                    style: titleStyle,
                                    textAlign: TextAlign.center,
                                  )),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              widget.content != null
                                  ? Container(
                                width: width * 0.7,
                                child: Text(
                                  '$content',
                                  style: thisContentStyle,
                                  textAlign: TextAlign.center,
                                ),
                              )
                                  : SizedBox(),
                              SizedBox(
                                height: widget.content == null ? 0 : height * 0.01,
                              ),
                              Theme(
                                data: ThemeData(
                                    primaryColor: Colors.grey[300],
                                    accentColor: Colors.blue
                                ),
                                child: Container(
                                  width: width * 0.68,
                                  child: TextField(
                                    controller: widget.editingController,
                                    style: contentStyle,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: _DialogActions(
                          dialogType: DialogType.Input,
                          okTapped: widget.okTapped,
                          cancelTapped: widget.cancelTapped,
                          buttonLabels: widget.buttonLabels,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
//        Positioned(
//          top: (height * 0.362) - (height * 0.05),
//          child: _CircularDialogHeader(
//            dialogType: DialogType.Confirmation,
//          ),
//        )
      ],
    );
  }
}



class _DialogActions extends StatelessWidget {
  final DialogType dialogType;
  final GestureTapCallback okTapped;
  final GestureTapCallback cancelTapped;
  final List<String> buttonLabels;

  _DialogActions({
    @required this.dialogType,
    this.okTapped,
    this.cancelTapped,
    this.buttonLabels
  }) : assert(dialogType != null);

  Widget _getDialogActions(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    switch (dialogType) {
      case DialogType.Alert:
        {
          return Container(
            width: width * 0.8,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[900].withOpacity(0.4),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      border: Border.all(
                          width: 0.5, color: Colors.grey[700])),
                  padding: EdgeInsets.all(width * 0.03),
                  child: Center(
                      child: Text(
                        buttonLabels != null ? buttonLabels[1] : 'Ok',
                        style: contentStyle,
                      ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: okTapped,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      case DialogType.Input:
      case DialogType.Confirmation:
        {
          return Container(
            width: width * 0.8,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[900].withOpacity(0.4),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20)),
                            border: Border.all(
                                width: 0.5, color: Colors.grey[700])),
                        padding: EdgeInsets.all(width * 0.03),
                        child: Center(
                            child: Text(
                              buttonLabels != null ? buttonLabels[0] : 'Cancel',
                              style: contentStyle,
                            )),
                      ),
                      Positioned.fill(
                        child: Material(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20)),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: cancelTapped,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[900].withOpacity(0.4),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20)),
                            border: Border.all(
                                width: 0.5, color: Colors.grey[700])),
                        padding: EdgeInsets.all(width * 0.03),
                        child: Center(
                            child: Text(
                              buttonLabels != null ? buttonLabels[1] : 'Ok',
                              style: contentStyle,
                            )),
                      ),
                      Positioned.fill(
                        child: Material(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20)),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: okTapped,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      default:
        break;
    }
    return Center(
        child: Text(
          'Invalid DialogType!',
          style: contentStyle,
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getDialogActions(context);
  }
}

class _CircularDialogHeader extends StatelessWidget {
  final DialogType dialogType;
  final Icon headerIcon;

  _CircularDialogHeader({@required this.dialogType, this.headerIcon})
      : assert(dialogType != null);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 2 * (height * 0.05),
          width: 2 * (height * 0.05),
          decoration: BoxDecoration(
              color: Colors.grey[800].withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[400], width: 4)),
          child: Center(
            child: headerIcon != null
                ? headerIcon
                : Icon(
                    dialogType == DialogType.Confirmation
                     ? FontAwesomeIcons.question
                     : Icons.warning,
              color: Colors.yellow,
              size: 46,
            ),
          ),
        ),
      ),
    );
  }
}
