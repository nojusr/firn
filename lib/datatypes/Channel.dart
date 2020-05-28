
// data class to hold information about a channel
class Channel {

  Channel ({
    this.name,
    this.topic,
    this.modes,
  });


  String name;
  String topic;
  String modes;
  bool currentlyConnected = false;
  bool autojoin = false;

  List<String> connectedUsers;

}