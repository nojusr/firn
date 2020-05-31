import 'package:firn/FirnClient.dart';
import 'package:firn/datatypes/FirnConfig.dart';
import 'package:firn/events/MessageRecievedEvent.dart';

/// a basic hello world example
/// with extensive documentation
/// to get the users used to how the library works


void main() {
  String testServer = "irc.server.url";
  String testChannel = "#channel_name";
  String testNickname = "FirnBot";
  String testRealname = "FirnBot";

  /// the main IRC client
  FirnClient TestClient = new FirnClient();

  /// a configuration to connect to a server,
  /// the FirnClient class can handle many configurations
  /// see pool.dart
  FirnConfig TestConfig = new FirnConfig();

  TestConfig.server = testServer;
  TestConfig.nickname = testNickname;
  TestConfig.realname = testRealname;
  TestConfig.port = 6667;

  TestClient.addConfig(TestConfig);


  /// the globalEventController listens to any and all events,
  /// regardless of which server they came from
  TestClient.globalEventController.stream.listen((event) async {

    /// event is of type FirnEvent
    /// FirnEvent is a base class
    /// that only contains a name and
    /// a FirnConfig
    if (event.eventName == "ready") {
      print("Ready, joining channel");

      /// most FirnClient methods will require
      /// a FirnConfig to be sent with any other arguments
      TestClient.joinChannel(event.config, testChannel);
    }
  });


  TestClient.globalEventController.stream.listen((event) {
    /// FirnEvent.eventName is used to determine the
    /// type of the incoming event
    if (event.eventName == "privMsgRecieved") {
      MessageRecievedEvent msg = event; /// MessageRecievedEvent is an extension of FirnEvent

      /// msg.message is of type Message, check /lib/datatypes/IRCMessage.dart
      String target = msg.message.parameters[0];
      String message = msg.message.parameters[1];

      if (message.startsWith(event.config.nickname)) {
        TestClient.sendPrivMsg(event.config, target, "Hello!");
      }
    }
  });

  TestClient.connectToServers();
}