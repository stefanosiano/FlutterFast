// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _noAction = -99;

/// Base class for [FastBloc] state. It contains management of actions, additional data and validations.
abstract class FastBlocState {
  /// Action id to be performed. Defaults to [_noAction].
  int action = _noAction;

  /// Record that can be sent with the action.
  Record _actionData = ();

  /// List of validations that failed. They are updated through [FastBloc.getValidations].
  List<int> validations = [];

  FastBlocState({int? action}) {
    this.action = action ?? _noAction;
  }

  /// Returns whether the state contains an action to be performed
  bool isActionAvailable() => action != _noAction;

  FastBlocState copyWith();

  /// Copy the state and set [action] to perform and its optional [actionData].
  T _copyWithAction<T extends FastBlocState>(int? action, Record? actionData) => copyWith() as T
    ..action = action ?? _noAction
    .._actionData = actionData ?? ();

  /// Set [action] to perform and its optional [actionData] to the current state.
  T _withAction<T extends FastBlocState>(int? action, Record? actionData) => this as T
    ..action = action ?? _noAction
    .._actionData = actionData ?? ();

  /// Set [validations] to the current state.
  T _withValidations<T extends FastBlocState>(List<int>? validations) => this as T..validations = validations ?? [];

  /// Returns the data associated to the current [action].
  T actionData<T extends Record>() => _actionData as T;
}

/// Base class for [FastBlocEvent] events.
abstract class FastBlocEvent {}

/// Base class for blocs. It contains management of actions, additional data and validations.
/// It also register to streams and run "one-time" functions
abstract class FastBloc<Event extends FastBlocEvent, State extends FastBlocState> extends Bloc<Event, State> {
  /// Functions to run only once.
  final Map<String, List<void Function()>> _oneTimeFunctions = {};

  FastBloc(super.initialState);

  @override
  void on<E extends Event>(
    FutureOr<void> Function(E event, FastBlocEmitter<State> emit) handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>((event, emit) => handler(event, _baseEmitter(emit)), transformer: transformer);
  }

  /// Return a list of validations to be sent with the next state.
  @protected
  List<int> getValidations(State state) => [];

  /// Function that can be overridden to customize the [state] to emit. It's called on every [emit].
  @protected
  State beforeEmit(State state) => state;

  /// List of [StreamSubscriptions] the bloc listens to.
  final List<StreamSubscription<dynamic>> _streamSubscriptions = List.empty(growable: true);

  /// Register a new [StreamSubscriptions] the bloc will listen to.
  void registerSubscription(StreamSubscription<dynamic> subscription) => _streamSubscriptions.add(subscription);

  /// Run the function scheduled through [scheduleOneTimeFunction] associated to the [key].
  @protected
  void runOneTimeFunctions({required String key}) {
    _oneTimeFunctions.remove(key)?.forEach((f) => f.call());
  }

  /// Schedule a function that can be run through [runOneTimeFunctions], and associate it to the [key].
  @protected
  void scheduleOneTimeFunction({required String key, required void Function() function}) {
    _oneTimeFunctions.update(key, (value) => value..add(function), ifAbsent: () => [function]);
  }

  /// Clear the bloc, cancelling any [StreamSubscription] registered through [registerSubscription].
  Future<void> dispose() async {
    for (var element in _streamSubscriptions) {
      await element.cancel();
    }
    _streamSubscriptions.clear();
  }

  FastBlocEmitter<State> _baseEmitter(Emitter<State> emit) => FastBlocEmitter(emit, beforeEmit, getValidations);
}

/// Wrapper around [Emitter] to enable [FastBloc.beforeEmit] and state action management, through [withAction] or
/// [clearAction].
class FastBlocEmitter<State extends FastBlocState> implements Emitter<State> {
  final Emitter<State> _emit;
  final State Function(State state) _beforeEmit;
  final List<int> Function(State state) _getValidations;

  FastBlocEmitter(this._emit, this._beforeEmit, this._getValidations);

  @override
  void call(State state) {
    State newState = _beforeEmit(state);
    this._emit(newState._withAction(state.action, state._actionData)._withValidations(_getValidations(newState)));
  }

  /// Emit a new state enriching it with an [action] and optional [actionData].
  /// If [cleanAction] is true, another state with [_noAction] as [action] will be emitted after the first one.
  @protected
  void withAction(State state, {required int action, Record? actionData, bool cleanAction = true}) {
    State newState = (state)._withAction(action, actionData ?? ());
    _emit(newState);
    if (cleanAction) {
      _emit(newState._copyWithAction(_noAction, ()));
    }
  }

  /// Emit a new state (or the current one), with [_noAction] as [action] and removing the [actionData], to clear it.
  @protected
  void clearAction(State state) {
    _emit(state._withAction(_noAction, ()));
  }

  @override
  Future<void> forEach<T>(Stream<T> stream,
      {required State Function(T data) onData, State Function(Object error, StackTrace stackTrace)? onError}) {
    return _emit.forEach(stream, onData: onData, onError: onError);
  }

  @override
  bool get isDone => _emit.isDone;

  @override
  Future<void> onEach<T>(Stream<T> stream,
      {required void Function(T data) onData, void Function(Object error, StackTrace stackTrace)? onError}) {
    return _emit.onEach(stream, onData: onData, onError: onError);
  }
}
