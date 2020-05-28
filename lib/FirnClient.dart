library firn;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:firn/datatypes/Channel.dart';
import 'package:firn/datatypes/IRCPrefix.dart';
import 'package:firn/events/FirnEvent.dart';
import 'package:firn/events/ChannelEvent.dart';
import 'package:firn/events/NickNameChangedEvent.dart';
import 'package:firn/events/ServerConnectEvent.dart';
import 'package:firn/events/MessageRecievedEvent.dart';
import 'package:firn/parser/IRCMessageParser.dart';
import 'package:firn/datatypes/IRCMessage.dart';

class FirnClient {

  bool printDebug = false;

  /// client variables
  String realname;
  String nickname;
  String version = "Firn IRC Library v0.0.1 (client version unset)";


  /// server variables
  String server;
  int port;

  /// channel variables
  bool canJoinChannels = false;
  List<Channel> joinedChannels = List<Channel>();


  /// main event controller
  StreamController<FirnEvent> eventController = StreamController<FirnEvent>.broadcast();

  /// main socket for talking
  Socket serverConnectionSocket;

  /// bool to indicate connection status
  bool hasConnectedToServer = false;


  void connectToServer() {

    if (server == null || server == "") {
      throw Exception('IRCClient error: server not set');
    }

    Socket.connect(server, port).then((socket){
      print('conneted to $server, port $port');
      hasConnectedToServer = true;
      serverConnectionSocket = socket;


      utf8.decoder
          .bind(serverConnectionSocket)
          .transform(LineSplitter())
          .listen((event) {
        rawMessageHandler(event);
      });

      sendNickAndUser();

      eventController.add(ServerConnectedEvent(
        eventName: 'serverConnected',
        serverName: server,
        serverPort: port,
      ));

    });
  }

  void disconnectFromServer() {
    if (server == null || server == "") {
      throw Exception('IRCClient error: server not set');
    }

    if (hasConnectedToServer == false || serverConnectionSocket == null){
      throw Exception('IRCClient error: tried to dc when not connected');
    }

    sendLine('QUIT');
    hasConnectedToServer = false;
    serverConnectionSocket.destroy();
  }

  void sendLine(String input) {
    if (printDebug) {
      print('sending raw message: $input');
    }
    serverConnectionSocket.write('$input \r\n');
  }

  void sendPrivMsg(String target, String input) {
    if (input.length > 512) {
      throw Exception('IRCClient error: input longer than 512 chars');
    }
    sendLine('PRIVMSG $target :$input');
    eventController.add(MessageRecievedEvent(
      eventName: 'messageSent',
      message: Message(
        parameters: [target, input],
        prefix: IRCPrefix(
          nick: nickname,
        ),
      ),
    ));
  }

  void sendNickAndUser() {
    sendLine('NICK $nickname');
    sendLine('USER $nickname 0 * :$realname');
  }

  void sendNick() {
    sendLine('NICK $nickname');
  }

  void joinChannel(String chName) {
    sendLine('JOIN $chName');
  }

  void partChannel(String chName) {
    sendLine('PART $chName');
  }

  void sendCTCPResponse(String target, String prefix, String message, List<String> args) {

    if (args.length > 0) {
      String arguments = args.join(' ');
      sendLine('NOTICE $target \u0001$prefix $message $arguments\u0001');
    } else {
      sendLine('NOTICE $target \u0001$prefix $message\u0001');
    }

  }


  void rawMessageHandler(String input) {

    Message parsedMsg = IRCMessageParser.parseRawMessage(input);

    if (printDebug == true) {
      String dbgOutput = 'IRC Message: ${parsedMsg.line}';
      dbgOutput += '\nCommand: ${parsedMsg.command}';
      dbgOutput += '\nPrefix: ${parsedMsg.prefix}';
      dbgOutput += '\nParameters: ';
      for (int i = 0; i < parsedMsg.parameters.length; i++) {
        dbgOutput += '${parsedMsg.parameters[i]} ||';
      }
      dbgOutput += '\nTags:';
      parsedMsg.tags.forEach((key, value) {
        dbgOutput += '$key=$value;';
      });
      dbgOutput += '\n-------------------------';
      print(dbgOutput);
    }



    /// no other way to do this in dart
    /// everything has to go into one massive switch
    switch (parsedMsg.command) {
      case 'PING':
        sendLine('PONG :${parsedMsg.parameters[0]}');
        break;

      case '001':
        nickname = parsedMsg.parameters[0];
        break;

      case '002':
      case '003':
      case '251':
      case '252':
      case '254':
      case '255':
      case '265':
      case '266':
      case '250':
      case '253':
      case '396':
      case '042':
        ///skip useless stuff
        break;

      case '010': /// client told to change servers
        disconnectFromServer();
        server = parsedMsg.parameters[0];
        port = int.parse(parsedMsg.parameters[1]);
        connectToServer();
        break;

      case '433': /// nickname in use
        nickname = '${nickname}_';
        break;

      case 'NOTICE':

        eventController.add(new MessageRecievedEvent(
          message: parsedMsg,
          eventName: 'noticeRecieved',
        ));
        break;

      case 'NICK': /// nickname change

        String _from = parsedMsg.prefix.nick;
        String _to = parsedMsg.parameters[0];

        for (Channel channel in joinedChannels) {
          List<String> users = channel.connectedUsers;
          int index = users.indexWhere((element) {
            if (element == _from) {
              return true;
            }
            return false;
          });
          if (index != -1) {
            channel.connectedUsers[index] = _to;
          }
        }

        eventController.add(new NicknameChangedEvent(
          eventName: 'nicknameChanged',
          from: _from,
          to: _to,
        ));
        break;

      case 'PRIVMSG':

        /// CTCP handling
        String ctcpChk = parsedMsg.parameters[1];
        if (ctcpChk[0] == '\u0001' && ctcpChk.substring(ctcpChk.length-1) == '\u0001') {
          String parsedNotice = ctcpChk.substring(1, ctcpChk.length-1);
          CTCPMessageHandler(parsedMsg, parsedNotice);
          break;
        }
        eventController.add(new MessageRecievedEvent(
          message: parsedMsg,
          eventName: 'privMsgRecieved',
        ));
        break;

      case '376': /// motd finish, ready to join
        canJoinChannels = true;
        eventController.add(new FirnEvent(
          eventName: 'ready',
        ));
        break;

      case '331': /// joined a channel without a topic
        Channel connChannel = new Channel();
        connChannel.name = parsedMsg.parameters[1];
        connChannel.topic = "";
        joinedChannels.add(connChannel);
        eventController.add(ChannelEvent(
          eventName: 'channelJoined',
          channel: connChannel,
        ));
        break;

      case '332': /// channel and topic recieved
        Channel connChannel = new Channel();
        connChannel.name = parsedMsg.parameters[1];
        connChannel.topic = parsedMsg.parameters[2];
        joinedChannels.add(connChannel);
        eventController.add(ChannelEvent(
          eventName: 'topicChanged',
          channel: connChannel,
        ));
        break;

      case '353': /// NAMES
        String nameStr = parsedMsg.parameters[3];
        List<String> names = nameStr.split(' ');

        String channelName = parsedMsg.parameters[2];

        Channel channel = joinedChannels.firstWhere((element) {
          if (element.name == channelName) {
            return true;
          }
          return false;
        });

        if (channel == null) {
          break;
        }

        if (channel.connectedUsers == null) {
          channel.connectedUsers = names;
        } else {
          channel.connectedUsers.addAll(names);
        }

        eventController.add(ChannelEvent(
          eventName: 'channelNamesRecieved',
          channel: channel,
        ));

        break;
    }
  }

  /// function to handle CTCP messages
  void CTCPMessageHandler(Message parsedMsg, String parsedNotice) {


    // parse and get command
    String command = parsedNotice.split(' ')[0];
    List<String> arguments = parsedNotice.split(' ').sublist(1);

    if (printDebug == true) {
      String dbgOutput = 'CTCP Message:\n';
      dbgOutput += '$parsedNotice\n';
      dbgOutput += 'parsed command: $command\n';
      dbgOutput += 'parsed command args: $arguments\n';
      dbgOutput += '\n------------------------';
      print(dbgOutput);
    }


    switch(command) {
      case 'PING':

        int timeGiven = int.parse(arguments[0]);


        int currentTime = DateTime.now().millisecondsSinceEpoch;

        print(currentTime);
        print(timeGiven*1000);

        int diff = currentTime-(timeGiven*1000);

        sendCTCPResponse(parsedMsg.prefix.nick, command, 'took $diff ms to respond', []);
        break;
      case 'VERSION':
        sendCTCPResponse(parsedMsg.prefix.nick, command, version, []);
        break;

    }

  }
}