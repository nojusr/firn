
import 'dart:async';
import 'dart:math';

import 'package:firn/events/ChannelEvent.dart';
import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/FirnConfig.dart';
import 'package:firn/events/MessageRecievedEvent.dart';
import 'package:firn/events/NickNameChangedEvent.dart';

/// data class to hold information about a channel
class Channel {

  Channel ({
    this.name,
    this.topic,
    this.modes,
    this.connectedUsers,
    this.currentlyConnected,
    this.autojoin,
    this.config,
    this.channelEventBufferSize = 100,
    this.isDM,
  }){
    if (config.shouldBufferEvents == true){
      StreamSubscription chanSub = config.eventController.stream.listen((event) {
        channelEventListener(event);
      });
      config.subscribers.add(chanSub);
      channelStreamSub = chanSub;
    }
  }

  /// a function used to reset the config's event controller stream
  /// which may get replaced upon a reconnect
  void resetStream() {

    // cleanup
    if (channelStreamSub != null) {
      channelStreamSub.cancel();
    }
    config.subscribers.remove(channelStreamSub);

    // resubscription
    channelStreamSub = config.eventController.stream.listen((event) {
      channelEventListener(event);
    });

  }

  void channelEventListener(FirnEvent event) {
    bool shouldAddEvent = false;

    if (event is MessageRecievedEvent){
      if (event.message.parameters[0] == this.name) {
        shouldAddEvent = true;
      } else if (event.message.parameters[0] == config.nickname && event.message.prefix.nick == name) {
        shouldAddEvent = true;
      } else if (event.message.prefix.isServer && config.server == name) {
        shouldAddEvent = true;
      }
    } else if (event is ChannelEvent && event.channel.name == name) {
      shouldAddEvent = true;
    } else if (event is NicknameChangedEvent) {
      shouldAddEvent = true;
      if (event.from == name) {
        name = event.to;
      }
    }

    if (shouldAddEvent) {
      if (channelEventBuffer.length > channelEventBufferSize) {
        channelEventBuffer.removeLast();
      }
      channelEventBuffer.insert(0, event);
    }
  }


  /// a local variable used to hold the stream subscription of the channel's
  /// parent config
  StreamSubscription channelStreamSub;

  /// a bool used to determine if the channel is used to directly communicate
  /// with an used
  bool isDM = false;

  /// the [FirnConfig] that this channel belongs to
  FirnConfig config;

  /// the name of the channel
  String name;

  /// the topic of the channel
  String topic;

  /// the string for holding all of the modes of a channel
  String modes;

  /// the bool used to indicate if the client is currently connected to
  /// this channel
  bool currentlyConnected = false;

  /// the bool used to indicate if the client should autojoin this channel
  /// when connecting to a server
  bool autojoin = false;

  /// a list that holds all of the connected users' nicknames
  List<String> connectedUsers = List<String>();

  /// the amount of [FirnEvent]s the channel object is allowed to hold
  int channelEventBufferSize = 100;

  /// a list of [FirnEvent]s that are specific to this channel
  List<FirnEvent> channelEventBuffer = List<FirnEvent>();

}