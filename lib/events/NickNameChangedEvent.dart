import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/FirnConfig.dart';

class NicknameChangedEvent extends FirnEvent {
  NicknameChangedEvent({
    this.eventName,
    this.from,
    this.to,
    FirnConfig config,
  }): super(eventName: eventName, config: config);

  String eventName;
  String from;
  String to;


}