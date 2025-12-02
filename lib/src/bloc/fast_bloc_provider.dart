// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_fast/src/bloc/fast_bloc.dart';
import 'package:flutter_fast/src/bloc/disposing_fast_bloc_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Wrapper around [BlocProvider], that adds auto dispose of bloc, a [create] function to create the bloc and a
/// [blocListener], invoked only if [State.isActionAvailable]
/// The [child] which will have access to the bloc instance via `BlocProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a [Bloc] or [Cubit] can be provided to multiple widgets within a subtree.
///
/// ```dart
/// FastBlocProvider<MyBloc, MyState>(
///   create: (BuildContext context) => MyBloc(),
///   blocListener: (BuildContext context, MyState state) { ... },
///   disposeBloc: true,
///   child: ...,
/// );
/// ```
class FastBlocProvider<Bloc extends FastBloc<FastBlocEvent, State>, State extends FastBlocState>
    extends StatelessWidget {
  const FastBlocProvider(
      {super.key,
      required this.create,
      this.blocListener,
      bool disposeBloc = false,
      bool lazy = true,
      required this.child})
      : _lazy = lazy,
        _disposeBloc = disposeBloc;

  final Bloc Function(BuildContext context) create;
  final void Function(BuildContext context, State state)? blocListener;
  final bool _lazy;
  final bool _disposeBloc;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<Bloc>(
      create: create,
      lazy: _lazy,
      child: BlocListener<Bloc, State>(
        listenWhen: (context, state) => state.isActionAvailable(),
        listener: (BuildContext context, State state) => blocListener?.call(context, state),
        child: _disposeBloc ? DisposingFastBlocBuilder<Bloc>(builder: (context) => child) : child,
      ),
    );
  }
}
