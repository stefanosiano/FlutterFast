// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_fast/src/bloc/fast_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that disposes the associated [FastBloc].
class DisposingFastBlocBuilder<T extends FastBloc<dynamic, dynamic>> extends StatefulWidget {
  const DisposingFastBlocBuilder({super.key, required this.builder});

  final Widget Function(BuildContext) builder;

  @override
  State<DisposingFastBlocBuilder> createState() => _DisposingFastBlocBuilderState<T>();
}

class _DisposingFastBlocBuilderState<T extends FastBloc<dynamic, dynamic>> extends State<DisposingFastBlocBuilder<T>> {
  late FastBloc<dynamic, dynamic> _bloc;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void didChangeDependencies() {
    _bloc = context.read<T>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
