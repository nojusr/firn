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
import 'package:firn/datatypes/Message.dart';
import 'package:firn/datatypes/FirnConfig.dart';



class FirnClient {

  List<FirnConfig> configs = List<FirnConfig>();

  StreamController<FirnEvent> globalEventController = StreamController<FirnEvent>.broadcast();

  bool printDebug = false;

  void addConfig(FirnConfig conf) {
    configs.add(conf);
    if (conf.autoConnect == true) {
      connectToServer(conf);
    }
  }

  void removeConfig(FirnConfig conf) {

    for (StreamSubscription sub in conf.subscribers) {
      sub.cancel();
    }
    disconnectFromServer(conf);
    configs.remove(conf);
  }

  void getConfig(FirnConfig conf) {
    configs.firstWhere((element){
      if (element == conf) {
        return true;
      }
      return false;
    });
  }

  String getUserNameLevel(Channel channel, String nickname) {
    for (String user in channel.connectedUsers) {
      if (['@', '~', '%', '+'].contains(user[0])) {
        String strippedUser = user.substring(1);
        if (strippedUser == nickname) {
          return user[0];
        }
      } else {
        if (nickname == user) {
          return "";
        }
      }

    }
  }

  void connectToServers() {

    for (FirnConfig conf in configs) {
      connectToServer(conf);
    }
  }

  void connectToServer(FirnConfig conf) {
    if (conf.server == null || conf.server == "") {
      throw Exception('IRCClient error: server not set');
    }

    Socket.connect(conf.server, conf.port).then((socket) {
      print('conneted to ${conf.server}, port ${conf.port}');
      conf.hasConnectedToServer = true;
      conf.serverConnectionSocket = socket;

      if (conf.eventController.isClosed == true) {
        conf.eventController = StreamController<FirnEvent>.broadcast();
      }

      utf8.decoder
          .bind(conf.serverConnectionSocket)
          .transform(LineSplitter())
          .listen((event) {
        rawMessageHandler(conf, event);
      });

      sendNickAndUser(conf);

      // subscribe to global event ctrl
      StreamSubscription globalSub = conf.eventController.stream.listen((event) {
        globalEventController.add(event);
      });

      conf.subscribers.add(globalSub);


      if (conf.shouldBufferEvents == true) {
        StreamSubscription bufferSub = conf.eventController.stream.listen((event) {
          if (conf.localEventBuffer.length > conf.localEventBufferSize) {
            conf.localEventBuffer.removeLast();
          }
          conf.localEventBuffer.insert(0, event);
        });
        conf.subscribers.add(bufferSub);
      }


      conf.eventController.add(ServerConnectedEvent(
        eventName: 'serverConnected',
        serverName: conf.server,
        serverPort: conf.port,
        config: conf,
      ));

    });
  }

  void disconnectFromServer(FirnConfig conf) {
    if (conf.server == null || conf.server == "") {
      throw Exception('IRCClient error: server not set');
    }

    if (conf.hasConnectedToServer == false || conf.serverConnectionSocket == null){
      throw Exception('IRCClient error: tried to dc when not connected');
    }




    sendLine(conf, 'QUIT');

    for (StreamSubscription sub in conf.subscribers) {
      sub.cancel();
    }

    conf.joinedChannels.clear();
    conf.localEventBuffer.clear();
    conf.eventController.close();
    conf.hasConnectedToServer = false;
    conf.serverConnectionSocket.destroy();
  }

  void sendLine(FirnConfig conf, String input) {
    if (printDebug) {
      print('sending raw message: $input');
    }
    conf.serverConnectionSocket.write('$input \r\n');
  }

  void sendPrivMsg(FirnConfig conf, String target, String input) {
    if (input.length > 512) {
      throw Exception('IRCClient error: input longer than 512 chars');
    }
    sendLine(conf, 'PRIVMSG $target :$input');
    conf.eventController.add(MessageRecievedEvent(
      eventName: 'messageSent',
      message: Message(
        parameters: [target, input],
        prefix: IRCPrefix(
          nick: conf.nickname,
        ),
      ),
      config: conf,
    ));
  }

  void sendNickAndUser(FirnConfig conf) {
    sendLine(conf, 'NICK ${conf.nickname}');
    sendLine(conf, 'USER ${conf.nickname} 0 * :${conf.realname}');
  }

  void sendNick(FirnConfig conf) {
    sendLine(conf, 'NICK ${conf.nickname}');
  }

  void joinChannel(FirnConfig conf, String chName) {
    sendLine(conf, 'JOIN $chName');
  }

  void partChannel(FirnConfig conf, String chName) {
    sendLine(conf, 'PART $chName');
  }

  void authenticate(FirnConfig conf, String user, String password) {
    sendLine(conf, 'AUTH $user $password');
  }
  
  void sendCTCPResponse(FirnConfig conf, String target, String prefix, String message, List<String> args) {

    if (args.length > 0) {
      String arguments = args.join(' ');
      sendLine(conf, 'NOTICE $target \u0001$prefix $message $arguments\u0001');
    } else {
      sendLine(conf, 'NOTICE $target \u0001$prefix $message\u0001');
    }

  }


  void rawMessageHandler(FirnConfig conf, String input) {

    Message parsedMsg = IRCMessageParser.parseRawMessage(input);

    if (printDebug == true) {
      String dbgOutput = 'IRC Message: ${parsedMsg.line}';
      dbgOutput += '\nCommand: ${parsedMsg.command}';
      dbgOutput += '\nPrefix:';

      if (parsedMsg.prefix != null) {
        if (parsedMsg.prefix.host != null) {
          dbgOutput += '|h: ${parsedMsg.prefix.host}';
        }
        if (parsedMsg.prefix.nick != null) {
          dbgOutput += '|n: ${parsedMsg.prefix.nick}';
        }
        if (parsedMsg.prefix.user != null) {
          dbgOutput += '|u: ${parsedMsg.prefix.user}';
        }
      }
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
        sendLine(conf, 'PONG :${parsedMsg.parameters[0]}');
        break;

      case '001':
        conf.nickname = parsedMsg.parameters[0];
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
        /// skip useless stuff
        break;

      case '010': /// client told to change servers
        disconnectFromServer(conf);
        conf.server = parsedMsg.parameters[0];
        conf.port = int.parse(parsedMsg.parameters[1]);
        connectToServer(conf);
        break;

      case '433': /// nickname in use
        conf.nickname = '${conf.nickname}_';
        sendNick(conf);
        break;

      case 'NOTICE':
        if (parsedMsg.line.contains("You are now logged in as ")) {
          conf.eventController.add(new MessageRecievedEvent(
            message: parsedMsg,
            eventName: 'authenticated',
            config: conf,
          ));
        } else {
          conf.eventController.add(new MessageRecievedEvent(
            message: parsedMsg,
            eventName: 'noticeRecieved',
            config: conf,
          ));
        }

        break;

      case 'NICK': /// nickname change

        String _from = parsedMsg.prefix.nick;
        String _to = parsedMsg.parameters[0];

        for (Channel channel in conf.joinedChannels) {
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

        conf.eventController.add(new NicknameChangedEvent(
          eventName: 'nicknameChanged',
          from: _from,
          to: _to,
          config: conf,
        ));
        break;

      case 'PRIVMSG':

        /// CTCP handling
        String ctcpChk = parsedMsg.parameters[1];
        if (ctcpChk[0] == '\u0001' && ctcpChk.substring(ctcpChk.length-1) == '\u0001') {
          String parsedNotice = ctcpChk.substring(1, ctcpChk.length-1);
          CTCPMessageHandler(conf, parsedMsg, parsedNotice);
          break;
        }
        conf.eventController.add(new MessageRecievedEvent(
          message: parsedMsg,
          eventName: 'privMsgRecieved',
          config: conf,
        ));
        break;

      case '376': /// motd finish, ready to join
        conf.canJoinChannels = true;
        conf.eventController.add(new FirnEvent(
          eventName: 'ready',
          config: conf,
        ));
        break;

      case '331': /// joined a channel without a topic

        Channel connChannel;

        connChannel = conf.joinedChannels.firstWhere((element) {
          if (element.name == parsedMsg.parameters[1]) {
            return true;
          }
          return false;
        }, orElse: () {
          conf.joinedChannels.add(Channel(
            name: parsedMsg.parameters[1],
          ));

          connChannel = conf.joinedChannels.firstWhere((element){
            if (element.name == parsedMsg.parameters[1]) {
              return true;
            }
            return false;
          });

        });


        connChannel.topic = "";

        break;

      case '332': /// channel and topic recieved

        Channel connChannel;

        connChannel = conf.joinedChannels.firstWhere((element) {
          if (element.name == parsedMsg.parameters[1]) {
            return true;
          }
          return false;
        }, orElse: () {
          conf.joinedChannels.add(Channel(
            name: parsedMsg.parameters[1],
            topic: "no topic set",
          ));

          connChannel = conf.joinedChannels.firstWhere((element){
            if (element.name == parsedMsg.parameters[1]) {
              return true;
            }
            return false;
          });

        });

        connChannel.topic = parsedMsg.parameters[2];

        conf.eventController.add(ChannelEvent(
          eventName: 'topicChanged',
          channel: connChannel,
          config: conf,
        ));
        break;

      case 'JOIN':
        String channelName = parsedMsg.parameters[0];

        Channel channel = conf.joinedChannels.firstWhere((element) {
          if (element.name == channelName) {
            return true;
          }
          return false;
        }, orElse: () {
          conf.joinedChannels.add(Channel(
            name: channelName,
            topic: "no topic set",
          ));

        });

        if (conf.nickname == parsedMsg.prefix.nick) {
          conf.eventController.add(ChannelEvent(
            eventName: 'channelJoined',
            channel: channel,
            config: conf,
          ));

        }


        if (channel.connectedUsers == null) {
          channel.connectedUsers = List<String>();
        }

        if (parsedMsg.prefix.nick != conf.nickname) {
          channel.connectedUsers.add(parsedMsg.prefix.nick);
        }


        conf.eventController.add(ChannelEvent(
          eventName: 'userJoined',
          channel: channel,
          parameters: [parsedMsg.prefix.nick],
          config: conf,
        ));
        break;

      case 'PART':
        String channelName = parsedMsg.parameters[0];
          Channel channel = conf.joinedChannels.firstWhere((element) {
          if (element.name == channelName) {
            return true;
          }
          return false;
        });

        if (channel.connectedUsers == null) {
          break;
        }

        String level = getUserNameLevel(channel, parsedMsg.prefix.nick);

        channel.connectedUsers.remove("${level}${parsedMsg.prefix.nick}");

        conf.eventController.add(ChannelEvent(
          eventName: 'userLeft',
          channel: channel,
          parameters: [parsedMsg.prefix.nick],
          config: conf,
        ));
        break;

      case 'QUIT':
        for (Channel channel in conf.joinedChannels) {

          String level = getUserNameLevel(channel, parsedMsg.prefix.nick);
          String fullname = "${level}${parsedMsg.prefix.nick}";

          if (channel.connectedUsers.contains(fullname)) {
            channel.connectedUsers.remove(fullname);
          }
        }
        conf.eventController.add(ChannelEvent(
          eventName: 'userQuit',
          parameters: [parsedMsg.prefix.nick],
          config: conf,
        ));
        break;

      case '353': /// NAMES
        String nameStr = parsedMsg.parameters[3];
        List<String> names = nameStr.split(' ');

        String channelName = parsedMsg.parameters[2];

        Channel channel = conf.joinedChannels.firstWhere((element) {
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

        conf.eventController.add(ChannelEvent(
          eventName: 'channelNamesRecieved',
          channel: channel,
          config: conf,
        ));

        break;
      case '477':
        conf.eventController.add(ChannelEvent(
          eventName: 'authRequired',
          config: conf,
        ));
        break;
    }
  }

  /// function to handle CTCP messages
  void CTCPMessageHandler(FirnConfig conf, Message parsedMsg, String parsedNotice) {


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

        sendCTCPResponse(conf, parsedMsg.prefix.nick, command, 'took $diff ms to respond', []);
        break;
      case 'VERSION':
        sendCTCPResponse(conf, parsedMsg.prefix.nick, command, conf.version, []);
        break;

    }

  }
}
