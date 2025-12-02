import 'package:flutter/material.dart';

/// Container that builds different children based on screen size.
/// [large] screen is > 1000, [medium] is >= 600 and [small] is < 600.
/// [large] builder is used if [medium] is not set on medium screens.
/// If [small] is null, an empty [Container] is returned on small screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget Function(BuildContext context) large;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? small;

  const ResponsiveContainer({
    super.key,
    required this.large,
    this.medium,
    this.small,
  });

  @override
  Widget build(BuildContext context) => responsive(
        context,
        l: large,
        s: small,
        m: medium,
        defValue: () => Container(),
      );
}

/// Call different functions based on screen size.
/// [l] screen is > 1000, [m] is >= 600 and [s] is < 600.
/// [l] builder is used if [m] is not set on medium screens.
/// If [s] is null, [defValue] is called on small screens.
T responsive<T>(
  BuildContext context, {
  required final T Function(BuildContext context) l,
  final T Function(BuildContext context)? m,
  final T Function(BuildContext context)? s,
  final T Function()? defValue,
}) {
  final double width = MediaQuery.sizeOf(context).width;
  return width > 1000
      ? l(context)
      : (width < 600)
          ? s?.call(context) ?? defValue!()
          : m?.call(context) ?? l(context);
}

/// Return different values based on screen size.
/// [l] screen is > 1000, [m] is >= 600 and [s] is < 600.
/// [l] builder is used if [m] is not set on medium screens.
/// If [s] is null, [defValue] is returned on small screens.
T responsiveValue<T>(
  BuildContext context, {
  required final T l,
  final T? m,
  final T? s,
  final T? defValue,
}) {
  return responsive(
    context,
    l: (c) => l,
    m: m != null ? (c) => m : null,
    s: s != null ? (c) => s : null,
    defValue: defValue != null ? () => defValue : null,
  );
}
