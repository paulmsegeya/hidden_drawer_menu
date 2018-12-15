import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/controllers/hidden_drawer_controller.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/menu/item_hidden_menu.dart';

class HiddenDrawerMenuBloc {

  /// builder containing the drawer settings
  final HiddenDrawerMenu _hiddenDrawer;
  final TickerProvider vsync;

  /// controller responsible to animation of the drawer
  HiddenDrawerController _controller;

  /// itens used to list in menu
  List<ItemHiddenMenu> itensMenu = new List();

  /// stream used to control item selected
  StreamController<int> positionSelected = StreamController<int>();

  /// stream used to control in view itens of the menu
  StreamController<List<ItemHiddenMenu>> listItensMenu =  StreamController<List<ItemHiddenMenu>>();

  /// stream used to control screen selected
  StreamController<int> screenSelected =  StreamController<int>();

  /// stream used to control title
  StreamController<String> tittleAppBar = StreamController<String>();

  /// stream used to control animation
  StreamController<double> contollerAnimation = StreamController<double>();

  /// stream used to control drag axisX
  StreamController<double> contollerDragHorizontal = StreamController<double>();

  /// stream used to control endrag
  StreamController<void> contollerEndDrag = StreamController<void>();

  double _actualPositionDrag = 0;
  bool _startDrag = false;

  HiddenDrawerMenuBloc(this._hiddenDrawer, this.vsync) {

    _hiddenDrawer.screens.forEach((item) {
      itensMenu.add(item.itemMenu);
    });

    listItensMenu.sink.add(itensMenu);
    tittleAppBar.sink.add(itensMenu[_hiddenDrawer.initPositionSelected].name);

    positionSelected.stream.listen((position) {
      tittleAppBar.sink.add(itensMenu[position].name);
      screenSelected.sink.add(position);
      toggle();
    });

    _controller = new HiddenDrawerController(
      vsync: vsync,
    )..addListener(() {
      var animatePercent = _controller.value;
      switch (_controller.state) {
        case MenuState.closed:
          animatePercent = 0.0;
          break;
        case MenuState.open:
          animatePercent = 1.0;
          break;
        case MenuState.opening:
          break;
        case MenuState.closing:
          break;
      }
      contollerAnimation.sink.add(animatePercent);
    });

    contollerDragHorizontal.stream.listen((position){
      _startDrag = true;
      _actualPositionDrag = position;
      contollerAnimation.sink.add(position);
    });

    contollerEndDrag.stream.listen((v){
      if(_startDrag) {
        if (_actualPositionDrag > 0.5) {
          _controller.open(_actualPositionDrag);
        } else {
          _controller.close(_actualPositionDrag);
        }
        _startDrag = false;
      }
    });

  }

  dispose() {

    listItensMenu.close();
    screenSelected.close();
    tittleAppBar.close();
    contollerAnimation.close();
    positionSelected.close();
    contollerDragHorizontal.close();
    contollerEndDrag.close();

  }

  void toggle() {
    _controller.toggle();
  }

}
