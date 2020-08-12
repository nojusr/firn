import 'package:test/test.dart';
import 'package:firn/FirnClient.dart';
import 'package:firn/datatypes/Channel.dart';
import 'package:firn/events/MessageRecievedEvent.dart';
import 'package:firn/events/ChannelEvent.dart';
import 'package:firn/datatypes/FirnConfig.dart';

void main() {

  String testServer = "iglooirc.com";
  String testChannel = "#test";
  String testNickname = "FirnTest";
  String testPassword = "vibe_check";
  String testRealname = "FirnRealName";



  FirnClient TestClient = FirnClient();
  FirnConfig TestConf = FirnConfig();

  test('SASL smoke test',  () async {
    print ("console test");
    TestClient.printDebug = true;


    TestConf.shouldBufferEvents = true;
    TestConf.server = testServer;
    TestConf.nickname = testNickname;
    TestConf.password = testPassword;
    TestConf.realname = testRealname;
    TestConf.shouldUseSASL = true;
    TestConf.autoConnect = true;
    TestConf.port = 6667;



    TestClient.addConfig(TestConf);

    TestConf.eventController.stream.listen((event) async {
      if (event.eventName == "ready") {
        print("recieved Ready event, joining test channel");
        TestClient.joinChannel(event.config, testChannel);

      }
    });


    TestClient.globalEventController.stream.listen((event) async {
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

}