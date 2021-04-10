// Multi-Tab Helper Bloc, Created a separate file to avoid clutter in FMBloc
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MTHelperBloc{
  final _rndMAX = 8999;
  final _tabMapController = BehaviorSubject<Map<int, Widget>>();
  AnimationController _mtAnimationController;

  Map<int, Widget> _tabs = <int, Widget>{};
  Widget _initChild;

  Stream<Map<int, Widget>> get tabs => _tabMapController.stream;
  void setMTAnimationController(AnimationController controller) => _mtAnimationController = controller;

  void toggleMTAnimation(){
    _mtAnimationController.isDismissed ? _mtAnimationController.forward() : _mtAnimationController.reverse();
  }

  int generateTabID(){
    var rng = Random();
    int tabID = (rng.nextInt(_rndMAX) + 1000);
    while(_tabs.containsKey(tabID)){
      tabID = generateTabID();
    }
    return tabID;
  }

  int setInitChild(int tabID, Widget initChild){
    _initChild = initChild;
    return addTab(tabID, initChild);
  }

  // Adds a tab and returns the tabID
  int addTab(int tabID, Widget newTab){
    _tabs[tabID] = newTab;
    _tabMapController.add(_tabs);
    return tabID;
  }

  void removeTab(int tabID){
    _tabs.remove(tabID);
    _tabMapController.add(_tabs);
  }
}