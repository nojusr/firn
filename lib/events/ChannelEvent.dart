import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/FirnConfig.dart';
import 'package:firn/datatypes/Channel.dart';

/// an abstract event that contains information
/// about a channel (event is sent when joining,
class ChannelEvent extends FirnEvent {

  ChannelEvent({
    this.eventName,
    this.channel,
    FirnConfig config,
  }): super(eventName: eventName, config: config);

  String eventName;
  Channel channel;
}