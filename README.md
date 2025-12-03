<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Flutter Fast (**F**lutter **A**pp **S**implified developmen**T**)

This is a library to simplify development of Flutter apps by providing base classes and annotation for code generation through [Flutter Fast Generator](https://github.com/stefanosiano/FlutterFastGenerator).

Note:  
While this library should be safe to use, it has not been properly released and lacks tests, and it's still considered work in progress.

## Features


### State Management / BLoC integration: Exports under `flutter_fast_bloc.dart`

Depends on `flutter_bloc`

- FastBloc: Base class for blocs. It contains management of actions, additional data and validations. It also register to streams and run "one-time" functions
- FastBlocProvider: Wrapper around `BlocProvider`, that adds auto dispose of bloc, a `create` function to create the bloc and a `blocListener` invoked only if FastBloc instance's `isActionAvailable` is true
- DisposingFastBlocBuilder: Widget that disposes the associated `FastBloc` when not needed anymore, through its extendable `dispose()` method


### Local Database helpers (SQLite): Exports under `flutter_fast_database.dart`

Depends on `sqflite` (+ ffi versions) and `path_provider`

These classes are used in code generation by [Flutter Fast Generator](https://github.com/stefanosiano/FlutterFastGenerator) offering helpers to work with sqflite.
- FastDao: simple interface without any logic, used to force import of flutter_fast_database.dart
- FastDaoMixin: contains the logic to parse Dart objects from/to database field
- FastDaoConverter: converters used to convert specific Dart types into sqlite types
- FastDatabaseHelper: handles the database, daos, table update callbacks and migrations


### Preferences management: Exports under `flutter_fast_preferences.dart`

Depends on `shared_preferences`

These classes are used in code generation by [Flutter Fast Generator](https://github.com/stefanosiano/FlutterFastGenerator) offering helpers to work with Shared Preferences, but can be used independently, too.

- FastPreferenceManager: handles logic to save and get values, delayed saves and real time callbacks on value update
- FastPreference: Objects that contains preference key, default value, stream for value updates, preference file name and custom encoding/decoding functions, if needed


### Repository abstraction: Exports under `flutter_fast.dart`

These classes are used in code generation by [Flutter Fast Generator](https://github.com/stefanosiano/FlutterFastGenerator) offering helpers to work with Shared Preferences, but can be used independently, too.

- FastRepository: handle logic to subscribe to streams and call callbacks when their values get updated

### Annotations for code generation: Exports under `flutter_fast_annotations.dart`

@Dao, @Query, @Queryable, @BlocEventState, @Pref


### Widgets collection: Exports under `flutter_fast_widgets.dart`

- AnimatedStack, FadingStack, AnimatedUnderlineContainer
- DoubleFacedContainer, DropdownContainer, ResponsiveContainer
- ListRows, TappableMouseRegion, TextControllerOnChangeListener


### Dependencies

The dependencies are used only when specific module is imported, so you don't have to bundle all of them.


## Getting started

The library is not published, yet, but can be used via git, by adding it to the `pubspec.yaml` file:

```yaml
dependencies:
    flutter_fast:
        git:
        url: https://github.com/stefanosiano/FlutterFast.git
```


## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```
