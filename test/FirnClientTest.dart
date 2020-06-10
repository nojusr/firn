import 'package:test/test.dart';
import 'package:firn/FirnClient.dart';
import 'package:firn/datatypes/Channel.dart';
import 'package:firn/events/MessageRecievedEvent.dart';
import 'package:firn/events/ChannelEvent.dart';
import 'package:firn/datatypes/FirnConfig.dart';

void main() {

  String testServer = "irc.rizon.net";
  String testChannel = "#homescreen";
  String testNickname = "FirnTest";
  String testRealname = "FirnRealName";

  String testServer2 = "iglooirc.com";
  String testChannel2 = "#igloo";


  FirnClient TestClient = FirnClient();
  FirnConfig TestConf = FirnConfig();
  FirnConfig TestConf2 = FirnConfig();

  test('Connection smoke test',  () {
    TestClient.printDebug = true;


    TestConf.shouldBufferEvents = true;
    TestConf.server = testServer;
    TestConf.nickname = testNickname;
    TestConf.realname = testRealname;
    TestConf.autoConnect = true;
    TestConf.port = 6667;

    TestConf2.server = testServer2;
    TestConf2.nickname = testNickname;
    TestConf2.realname = testRealname;
    TestConf2.autoConnect = true;
    TestConf2.port = 6667;


    TestClient.addConfig(TestConf);
    TestClient.addConfig(TestConf2);

    TestConf.eventController.stream.listen((event) async {
      if (event.eventName == "ready") {
        print("recieved Ready event, joining test channel");
        TestClient.joinChannel(event.config, testChannel);

      }
    });

    TestConf2.eventController.stream.listen((event) {
      if (event.eventName == "ready") {
        print("recieved Ready event, joining test channel");
        TestClient.joinChannel(event.config, testChannel2);

      }
    });

    TestClient.globalEventController.stream.listen((event) {
      print("testconf2 events recieved: ${event.config.localEventBuffer.length}");
      print("time of event: ${event.timestamp.toIso8601String()}");
    });

    TestClient.globalEventController.stream.listen((event) {
      if (event.eventName == "privMsgRecieved") {
        MessageRecievedEvent msg = event;
        String target = msg.message.parameters[0];
        String message = msg.message.parameters[1];
        if (message.startsWith(event.config.nickname)) {
          TestClient.sendPrivMsg(event.config, target, "HEY! that's me!");
        } else if (message == "fuck you") {
          TestClient.sendPrivMsg(event.config, target, "You'd like me to wouldn't you");
        } else if (message == "pls leave") {
          TestClient.sendPrivMsg(event.config, target, "Fine.");
          TestClient.partChannel(event.config, target);
          TestClient.disconnectFromServer(event.config);
        }
      }
    });
  });


  TestClient.globalEventController.stream.listen((event) async {
    if (event.eventName == "channelNamesRecieved") {
      print("recieved and parsed channel names");
      ChannelEvent evnt = event;
      Channel chan = evnt.channel;
      print("channelInfo:");
      String output = "Channel: ${chan.name}\n";
      output += "Topic: ${chan.topic}\n";
      output += "Users: ";
      for (int i = 0; i < chan.connectedUsers.length; i++) {
        output += "${chan.connectedUsers[i]}, ";
      }
      output += "\n";
      output += "------------------------------";
      print(output);
    }
  });

}