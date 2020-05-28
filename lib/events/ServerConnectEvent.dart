import 'package:firn/events/FirnEvent.dart';

class ServerConnectedEvent extends FirnEvent {

  ServerConnectedEvent({
    this.eventName,
    this.serverName,
    this.serverPort,
  });


  String eventName;
  int timestamp;

  String serverName;
  int serverPort;

}