import 'package:firn/datatypes/Channel.dart';
import 'package:firn/events/FirnEvent.dart';
import 'dart:io';
import 'dart:async';

/// a class that holds any and all required variables for
/// a connection to an IRC server via FirnClient
class FirnConfig {
  /// client variables
  String realname;
  String nickname;
  String version = "Firn IRC Library v0.0.1 (client version unset)";


  /// server variables
  String server;
  int port;
  bool autoConnect = false;

  /// channel variables
  bool canJoinChannels = false;
  List<Channel> joinedChannels = List<Channel>();


  /// main event controller
  StreamController<FirnEvent> eventController = StreamController<FirnEvent>.broadcast();

  /// event controller subscribers
  List<StreamSubscription> subscribers = List<StreamSubscription>();

  /// main socket for talking to server
  Socket serverConnectionSocket;

  /// bool to indicate connection status
  bool hasConnectedToServer = false;

}