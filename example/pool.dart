import 'package:firn/FirnClient.dart';
import 'package:firn/datatypes/FirnConfig.dart';
import 'package:firn/events/MessageRecievedEvent.dart';

/// an example showing how Firn
/// can be used to connect to multiple
/// servers at the same time.

void main() {
  String testServer = "irc.server.url";
  String testServer2 = "irc.secondserver.url";
  String testChannel = "#channel_name";
  String testChannel2 = "#2nd_channel_name";
  String testNickname = "FirnBot";
  String testRealname = "FirnBot";

  /// the main IRC client
  FirnClient TestClient = FirnClient();

  /// a configuration to connect to a server,
  /// the FirnClient class can handle many configurations
  /// see pool.dart
  FirnConfig TestConfig = FirnConfig();
  FirnConfig TestConfig2 = FirnConfig();

  TestConfig.server = testServer;
  TestConfig.nickname = testNickname;
  TestConfig.realname = testRealname;
  TestConfig.port = 6667;

  TestConfig2.server = testServer2;
  TestConfig2.nickname = testNickname;
  TestConfig2.realname = testRealname;
  TestConfig2.port = 6667;

  TestClient.addConfig(TestConfig);
  TestClient.addConfig(TestConfig2);


  /// Each FirnConfig has their own server-specific eventController,
  /// which can be used to do different things for different servers.
  ///
  /// For example, TestConfig is being told to join testChannel
  /// upon recieving a 'ready' event, while...

  TestConfig.eventController.stream.listen((event) async {
    if (event.eventName == "ready") {
      print("TestConfig Ready, joining channel");
      TestClient.joinChannel(event.config, testChannel);
    }
  });


  /// ...TestConfig2  is being told to join testChannel2
  /// upon recieving a 'ready' event.

  TestConfig2.eventController.stream.listen((event) async {
    if (event.eventName == "ready") {
      print("TestConfig2 Ready, joining channel");

      TestClient.joinChannel(event.config, testChannel2);
    }
  });


  /// However, as stated in basic.dart, the globalEventController listens
  /// to events in ALL FirnConfigs
  TestClient.globalEventController.stream.listen((event) {

    if (event.eventName == "privMsgRecieved") {

      /// Server specific information can still be acquired from
      /// the event
      FirnConfig serverConfig = event.config;

      /// serverConfig now contains the information
      /// of the server that the event was recieved from

      MessageRecievedEvent msg = event;
      String target = msg.message.parameters[0];
      String message = msg.message.parameters[1];

      if (message.startsWith(event.config.nickname)) {
        TestClient.sendPrivMsg(event.config, target, "Hello!, Message recieved from ${serverConfig.server}");
      }
    }
  });

  TestClient.connectToServers();
}