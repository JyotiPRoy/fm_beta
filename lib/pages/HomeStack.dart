// NOTE: This is the Stack which contains the Drawer and the Multi-Tab Stack

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/BlocProvider.dart';
import 'package:fm_beta/bloc/MTHelperBloc.dart';
import 'package:fm_beta/pages/HomePage.dart';
import 'package:fm_beta/widgets/CustomDrawer.dart';
import 'package:fm_beta/pages/MultiTabPage.dart';

class HomeStack extends StatefulWidget {
  final MTHelperBloc mtBloc;

  HomeStack({this.mtBloc});

  @override
  _HomeStackState createState() => _HomeStackState();
}

class _HomeStackState extends State<HomeStack> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation scaleTween;
  Animation slideTween;
  double _hBorderRadius = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    scaleTween = Tween(begin: 1, end: 0.77).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCirc));
    slideTween = Tween(begin: 0, end: 0.65).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCirc));
    addMTBlocInitChild();
  }

  void addMTBlocInitChild(){
    final mtBloc = widget.mtBloc;
    int homeID = mtBloc.generateTabID();
    final home = HomePage(
      userName: 'Rachel',
      menuToggle: toggle,
      mtID: homeID,
      menuController: _animationController,
    );
    var id = mtBloc.setInitChild(homeID, home);
    print('ID: $id');

    // It may seem as a bad idea since we can handle it in toggle() itself,
    // but the controller has been sent to HomePage and so this is required
    _animationController.addStatusListener((status) {
      if(status == AnimationStatus.dismissed){
        changeBorderRadius();
      }
    });
  }

  void toggle(){
    if(_animationController.isDismissed){
      _animationController.forward();
      changeBorderRadius();
    }else{
      _animationController.reverse();
    }
  }

  void changeBorderRadius(){
    setState(() {
      _hBorderRadius = _hBorderRadius == 30 ? 0 : 30;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _){
        double slide = width * slideTween.value;
        double scale = 1.0 * scaleTween.value; // Removing the 1.0 * gives errors T_T
        return Stack(
          children: [
            // Drawer
            CustomDrawer(),
            // Multi-Tab Stack
            GestureDetector(
              onTap: (){
                if(!_animationController.isDismissed){
                  toggle();
                }
              },
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(_hBorderRadius)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: Offset(-4, 2),
                          blurRadius: 8,
                        ),
                      ]
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MultiTabPage(
                    mtBloc: widget.mtBloc,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
