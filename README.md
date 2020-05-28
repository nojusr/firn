![firn logo](https://kelp.ml/u/axdx.png)
# firn
The chillest IRC library.

# NOTICE
This library is still in heavy development, things are very likely to change in the future.

## What is firn?
Firn is modern IRC v3 library written in pure dart. Used in Igloo IRC for android.

## How does it work?
Firn relies on an object-based event stream. Any important messages coming from a server
are parsed and sent through this event stream. This stream can have any number of listeners.

## Basic example
```dart
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

```
