import 'dart:io';

import 'package:test/test.dart';
import 'package:firn/FirnClient.dart';
import 'package:firn/datatypes/Channel.dart';
import 'package:firn/events/MessageRecievedEvent.dart';
import 'package:firn/events/ChannelEvent.dart';

void main() {

  String testServer = "irc.rizon.net";
  String testChannel = "#homescreen";
  String testNickname = "FirnTest";
  String testRealname = "FirnRealName";

  FirnClient TestClient = new FirnClient();


  test('Connection smoke test',  () {
    TestClient.printDebug = true;
    TestClient.server = testServer;
    TestClient.nickname = testNickname;
    TestClient.realname = testRealname;
    TestClient.port = 6667;

    TestClient.connectToServer();

    TestClient.eventController.stream.listen((event) async {
      if (event.eventName == "ready") {
        print("recieved Ready event, joining test channel");
        TestClient.joinChannel(testChannel);

      }
    });


    TestClient.eventController.stream.listen((event) {
      if (event.eventName == "privMsgRecieved") {
        MessageRecievedEvent msg = event;

        String target = msg.message.parameters[0];
        String message = msg.message.parameters[1];
        if (message.startsWith(TestClient.nickname)) {
          TestClient.sendPrivMsg(target, "HEY! that's me!");
        } else if (message == "fuck you") {
          TestClient.sendPrivMsg(target, "You'd like me to wouldn't you");
        } else if (message == "pls leave") {
          TestClient.sendPrivMsg(target, "Fine.");
          TestClient.partChannel(target);
          TestClient.disconnectFromServer();
        }

      }
    });
  });

  TestClient.eventController.stream.listen((event) async {
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