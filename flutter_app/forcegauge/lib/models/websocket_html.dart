import 'package:web_socket_channel/html.dart';

class WebsocketGetter {
  static newWebsocket(String address) {
    return new HtmlWebSocketChannel.connect(address);
  }
}
