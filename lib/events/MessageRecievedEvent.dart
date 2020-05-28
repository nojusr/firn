import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/IRCMessage.dart';

class MessageRecievedEvent extends FirnEvent {
  MessageRecievedEvent({
    this.eventName,
    this.message
  });

  String eventName;
  int timestamp;
  Message message;
}