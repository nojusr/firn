import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/IRCMessage.dart';
import 'package:firn/datatypes/FirnConfig.dart';

class MessageRecievedEvent extends FirnEvent {
  MessageRecievedEvent({
    this.eventName,
    this.message,
    FirnConfig config,
  }): super(eventName: eventName, config: config);

  String eventName;
  int timestamp;
  Message message;
}