import 'package:firn/datatypes/IRCPrefix.dart';

/// static class used to parse IRC prefixes
class IRCPrefixParser {

  /// the main parsing method
  static IRCPrefix parsePrefix(String input) {
    if (input.length == null || input.length < 0) {
      return null;
    }

    int dpos = input.indexOf('.')+1;
    int upos = input.indexOf('!')+1;
    int hpos = input.indexOf('@', upos)+1;

    if (upos == 1 || hpos == 1) {
      return null;
    }

    IRCPrefix output = new IRCPrefix();
    output.raw = input;
    output.isServer = false;

    if (upos > 0) {
      output.nick = input.substring(0, upos-1);
      if (hpos > 0) {
        output.user = input.substring(upos, hpos-1);
        output.host = input.substring(hpos);
      } else {
        output.user = input.substring(upos);
      }
    } else if (hpos > 0) {
      output.nick = input.substring(0, hpos-1);
      output.host = input.substring(hpos);
    } else if (dpos > 0) {
      output.host = input;
      output.isServer = true;
    } else {
      output.nick = input;
    }
    return output;
  }
}