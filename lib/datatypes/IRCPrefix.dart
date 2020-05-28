
class IRCPrefix {

  IRCPrefix({
    this.raw,
    this.isServer,
    this.nick,
    this.user,
    this.host,
  });

  String raw;
  bool isServer = false;
  String nick;
  String user;
  String host;
}