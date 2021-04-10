import 'package:flutter/material.dart';
import 'package:fm_beta/bloc/MTHelperBloc.dart';
import 'package:fm_beta/bloc/fm_bloc.dart';


class BlocProvider extends InheritedWidget {
  final FileSystemBloc bloc;
  final MTHelperBloc mtBloc;

  BlocProvider({
    @required
    this.bloc,
    this.mtBloc,
    Widget child
  }) : super(child: child);

  static BlocProvider of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<BlocProvider>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}