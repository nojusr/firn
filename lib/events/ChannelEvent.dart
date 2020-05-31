import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/Channel.dart';
import 'package:firn/datatypes/FirnConfig.dart';
// event that contains info about a channel
class ChannelEvent extends FirnEvent {

  ChannelEvent({
    this.eventName,
    this.channel,
    FirnConfig config,
  }): super(eventName: eventName, config: config);

  String eventName;
  Channel channel;
}