import 'package:firn/datatypes/FirnConfig.dart';
class FirnEvent {

  FirnEvent({
    this.eventName,
    this.config,
  });

  String eventName;
  FirnConfig config;
}