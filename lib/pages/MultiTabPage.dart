import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/MTHelperBloc.dart';

class MultiTabPage extends StatefulWidget {
  final MTHelperBloc mtBloc;

  MultiTabPage({this.mtBloc});

  @override
  _MultiTabPageState createState() => _MultiTabPageState();
}

class _MultiTabPageState extends State<MultiTabPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation heightScaler;
  Animation widthScaler;
  Animation paddingTween;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    widget.mtBloc.setMTAnimationController(controller);
    heightScaler = Tween(begin: 1, end: 0.75).animate(controller);
    widthScaler = Tween(begin: 1, end: 0.8).animate(controller);
    paddingTween = Tween<double>(begin: 0, end: 40).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // double _listHeight = height *  heightScaler.value;
    // double _listChildWidth = width *  widthScaler.value;
    return Material(
      child: Container(
        color: Colors.red,
        child: StreamBuilder<Map<int, Widget>>(
          stream: widget.mtBloc.tabs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, _){
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index){
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: paddingTween.value, vertical: paddingTween.value/2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            height: height * heightScaler.value,
                            width: width * widthScaler.value,
                            child: snapshot.data.values.elementAt(index),
                          ),
                        ),
                      );
                    },
                  );
                }
              );
            } else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
