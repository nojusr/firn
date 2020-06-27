import 'package:firn/events/FirnEvent.dart';
import 'package:firn/datatypes/FirnConfig.dart';
import 'package:firn/datatypes/Channel.dart';

/// an abstract event that contains information
/// about a channel
class ChannelEvent extends FirnEvent {

  ChannelEvent({
    this.eventName,
    this.channel,
    this.parameters,
    FirnConfig config,
  }): super(eventName: eventName, config: config);

  List<String> parameters;
  String eventName;
  Channel channel;
}