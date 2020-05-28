import 'package:firn/events/FirnEvent.dart';

class NicknameChangedEvent extends FirnEvent {
  NicknameChangedEvent({
    this.eventName,
    this.from,
    this.to,
  });

  String eventName;
  String from;
  String to;


}