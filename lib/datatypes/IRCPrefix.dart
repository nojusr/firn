
/// a data class that holds all required information
/// regarding the user/server that sent an IRC message
class IRCPrefix {

  IRCPrefix({
    this.raw,
    this.isServer = false,
    this.nick,
    this.user,
    this.host,
  });

  /// the raw, unparsed prefix
  String raw;

  /// used to tell if message was sent by a server or not
  bool isServer = false;

  /// nickname (stays as null if [isServer] is true
  String nick;

  /// username
  String user;

  /// the host of the prefix (use this instead of [nick] when [isServer] is true)
  String host;
}