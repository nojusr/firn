
/// data class to hold information about a channel
class Channel {

  Channel ({
    this.name,
    this.topic,
    this.modes,
  });

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
  List<String> connectedUsers;

}