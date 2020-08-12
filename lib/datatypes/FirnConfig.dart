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

  /// the password of the config (connection), this is used in order to authenticate
  /// the user with the server
  String password;

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

  /// A Bool to set if FirnClient should put any events that
  /// happened into [localEventBuffer], defaults to 'false'
  bool shouldBufferEvents = false;

  /// The maximum size of [localEventBuffer], defaults to '150'
  int localEventBufferSize = 150;

  /// A list of [FirnEvent] that stores any events that happened
  /// to it's [FirnConfig], depending on if [shouldBufferEvents] is true
  List<FirnEvent> localEventBuffer = List<FirnEvent>();


  /// The config's event controller
  StreamController<FirnEvent> eventController = StreamController<FirnEvent>.broadcast();

  /// event controller subscriber
  List<StreamSubscription> subscribers = List<StreamSubscription>();

  /// main TCP socket for talking to a server
  Socket serverConnectionSocket;

  /// bool to indicate connection status
  bool hasConnectedToServer = false;

  /// list of strings that contain all server capabilities
  List<String> serverListCapabilities = List<String>();

  /// list of strings that contain all explicitly confirmed
  /// server capabilities
  List<String> serverAckCapabilities = List<String>();

  /// bool to tell client if SASL is to be used
  bool shouldUseSASL = false;
}