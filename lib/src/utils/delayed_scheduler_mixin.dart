/// Mixin that provides a way to schedule one or more jobs in the future.
/// Scheduling the same job multiple times will reschedule it in the future, calling it only once.
mixin DelayedSchedulerMixin {
  final Map<String, DateTime> _scheduledTimes = {};
  final Map<String, Function> _scheduledFunctions = {};

  /// Schedule a [functionToRun], associated to a [key] and runs it after [delayMillis].
  /// If the same job is scheduled it multiple times, it will be rescheduled in the future and called only once.
  void schedule({required String key, Duration delay = const Duration(seconds: 2), required Function functionToRun}) {
    _scheduledTimes[key] = DateTime.now().add(delay);
    _scheduledFunctions[key] = functionToRun;
    Future.delayed(
      delay,
      () {
        if (_scheduledTimes[key]?.isBefore(DateTime.now()) != false) {
          _scheduledTimes.remove(key);
          _scheduledFunctions.remove(key)?.call();
        }
      },
    );
  }

  /// Run all scheduled functions and remove them from the queue.
  void flush() {
    _scheduledTimes.clear();
    _scheduledFunctions.forEach((key, value) {
      value();
    });
    _scheduledFunctions.clear();
  }
}
