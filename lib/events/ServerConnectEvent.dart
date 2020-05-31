import 'package:firn/datatypes/FirnConfig.dart';
import 'package:firn/events/FirnEvent.dart';

class ServerConnectedEvent extends FirnEvent {

  ServerConnectedEvent({
    this.eventName,
    this.serverName,
    this.serverPort,
    FirnConfig config,
  }): super(eventName: eventName, config: config);


  String eventName;
  String serverName;
  int serverPort;

}