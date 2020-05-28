import 'package:firn/FirnClient.dart';
import 'package:firn/events/MessageRecievedEvent.dart';


String testServer = "irc.server.url";
String testChannel = "#channel_name";
String testNickname = "FirnBot";
String testRealname = "FirnBot";

FirnClient TestClient = new FirnClient();

TestClient.server = testServer;
TestClient.nickname = testNickname;
TestClient.realname = testRealname;
TestClient.port = 6667;


TestClient.eventController.stream.listen((event) async {
  if (event.eventName == "ready") {
    print("Ready, joining channel");
    TestClient.joinChannel(testChannel);
  }
});


TestClient.eventController.stream.listen((event) {
  if (event.eventName == "privMsgRecieved") {

    MessageRecievedEvent msg = event;

    String target = msg.message.parameters[0];
    String message = msg.message.parameters[1];

    if (message.startsWith(TestClient.nickname)) {
      TestClient.sendPrivMsg(target, "Hello!");
    }
  }
});

TestClient.connectToServer();