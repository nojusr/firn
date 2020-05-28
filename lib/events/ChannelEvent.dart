import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/Channel.dart';

// event that contains info about a channel
class ChannelEvent extends FirnEvent {

  ChannelEvent({
    this.eventName,
    this.channel,
  });

  String eventName;
  Channel channel;
}