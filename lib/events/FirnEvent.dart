import 'package:firn/datatypes/FirnConfig.dart';

/// a base event class used in [FirnConfig]'s eventController
class FirnEvent {

  FirnEvent({
    this.eventName,
    this.config,
  });

  /// the name of the event
  String eventName;

  /// the [FirnConfig] of the event
  FirnConfig config;

  /// the timestamp of when the event happened
  DateTime timestamp = DateTime.now();
}