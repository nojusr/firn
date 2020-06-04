import 'package:firn/datatypes/Channel.dart';
import 'package:firn/events/FirnEvent.dart';
import 'dart:io';
import 'dart:async';

/// a data class that holds any and all required variables for
/// a connection to an IRC server via FirnClient
class FirnConfig {

  /// the 'real name' of the config. Usually sent when
  /// recieving a 'WHOIS' request
  String realname;

  /// the main nickname of the config, this is the name you and others
  /// see when you post something on IRC
  String nickname;

  /// the version of the client, sent upon recieving a `CTCP VERSION` request
  /// or a `VERSION` request from the server
  String version = "Firn IRC Library v0.0.2 (client version unset)";

  /// the server's URL
  String server;

  /// the client-side nickname for the server
  String serverNick;

  /// the server port, defaults to 6667
  int port = 6667;

  /// bool to tell if [FirnClient] should autoconnect upon adding the
  /// config to [FirnClient.configs] via [FirnClient.addConfig]
  bool autoConnect = false;

  /// used to indicate if config is able to join any channels
  bool canJoinChannels = false;

  /// stores any channels that are currently joined
  List<Channel> joinedChannels = List<Channel>();


  /// The config's event controller
  StreamController<FirnEvent> eventController = StreamController<FirnEvent>.broadcast();

  /// event controller subscriber
  List<StreamSubscription> subscribers = List<StreamSubscription>();

  /// main TCP socket for talking to a server
  Socket serverConnectionSocket;

  /// bool to indicate connection status
  bool hasConnectedToServer = false;

}