import 'package:firn/datatypes/IRCPrefix.dart';


/// IRC Message
class Message {
  /// Original Line
  String line;

  /// IRC Command
  String command;

  /// IRC Prefix
  IRCPrefix prefix;

  /// IRC v3 Tags
  Map<String, String> tags;

  /// Parameters
  List<String> parameters;

  /// Creates a new Message
  Message({
    this.line,
    this.command,
    this.prefix,
    this.parameters,
    this.tags
  });

  @override
  String toString () {
    String output = "IRC Message:";
    output += "Command: $command |";
    output += "Parameters: ";
    for (int i = 0; i < parameters.length; i++) {
      output += parameters[i] + " ";
    }
    output += "|Tags:";
    tags.forEach((key, value) {
      output += key + "=" + value+";";
    });
    return output;
  }

  bool get hasAccountTag => tags.containsKey("account");
  String get accountTag => tags["account"];

  bool get hasServerTime => tags.containsKey("time");
  DateTime get serverTime {
    if (_serverTime != null) {
      return _serverTime;
    } else {
      return _serverTime = DateTime.parse(tags["time"]);
    }
  }

  bool get isBatched => tags.containsKey("batch");
  String get batchId => tags["batch"];

  DateTime _serverTime;
}