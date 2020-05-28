import 'package:firn/parser/IRCPrefixParser.dart';
import 'package:firn/datatypes/IRCPrefix.dart';
import 'package:firn/datatypes/IRCMessage.dart';

class IRCMessageParser {

  static Message parseRawMessage(String input) {

    Message output = new Message();

    output.line = input;

    if (output.parameters == null) {
      output.parameters = List<String>();
    }

    if (output.tags == null) {
      output.tags = Map<String, String>();
    }

    int position = 0;
    int nextspace = 0;

    if (input[0] == '@') {

      nextspace = input.indexOf(' ');

      if (nextspace == -1) {
        throw Exception('IRCError: malformed message');
      }

      var rawTags = input.substring(1, nextspace).split(';');

      for (int i = 0; i < rawTags.length; i++) {
        var tag = rawTags[i];
        var pair = tag.split('=');
        output.tags[pair[0]] = pair[1];
      }

      position = nextspace+1;
    }

    while (input[position] == ' ') {
      position++;
    }

    if (input[position] == ':') {
      nextspace = input.indexOf(' ');

      if (nextspace == -1) {
        throw Exception('IRCError: malformed message');
      }

      output.prefix = IRCPrefixParser.parsePrefix(input.substring(position+1, nextspace));
      position = nextspace+1;

      while (input[position] == ' ') {
        position++;
      }
    }

    nextspace = input.indexOf(' ', position);

    if (nextspace == -1) {
      if (input.length > position) {
        output.command = input.substring(position);
        return output;
      }
      throw Exception('IRCError: malformed message');
    }

    output.command = input.substring(position, nextspace);

    position = nextspace+1;

    while (input[position] == ' ') {
      position++;
    }

    while (position < input.length) {
      nextspace = input.indexOf(' ', position);

      if (input[position] == ':') {
        output.parameters.add(input.substring(position+1));
        break;
      }

      if (nextspace != -1) {
        output.parameters.add(input.substring(position, nextspace));
        position = nextspace+1;

        while (input[position] == ' ') {
          position++;
        }
        continue;
      }

      if (nextspace == -1) {
        output.parameters.add(input.substring(position));
        break;
      }

    }

    return output;
  }

}
