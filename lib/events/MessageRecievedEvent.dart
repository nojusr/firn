import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/Message.dart';
import 'package:firn/datatypes/FirnConfig.dart';

/// event used to indicate whenever a server
/// connection has recieved a message
class MessageRecievedEvent extends FirnEvent {
  MessageRecievedEvent({
    this.eventName,
    this.message,
    FirnConfig config,
  }): super(eventName: eventName, config: config);

  String eventName;
  Message message;
}