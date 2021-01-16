import 'package:web_socket_channel/io.dart';

class WebsocketGetter {
  static newWebsocket(String address) {
    return new IOWebSocketChannel.connect(address);
  }
}
