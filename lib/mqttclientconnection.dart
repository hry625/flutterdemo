import 'dart:async';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientConnection {
  String server;
  String cID;
  int port;
  static List<String> subscribedTopic;
  MqttServerClient client;

  MqttClientConnection(String server, String clientID, int port) {
    server = this.server;
    clientID = this.cID;
    port = this.port;
  }

  Future<bool> subscribe(String topic, int qos) async {
    if (await _connectToBroker() == true) {
      client.onDisconnected = _onDisconnected;
      client.onConnected = _onConnected;
      client.onSubscribed = _onSubscribed;
      _subscribe(topic, qos);
      return true;
    }
    return false;
  }

  Future<bool> _connectToBroker() async {
    if (client != null &&
        client.connectionStatus.state == MqttConnectionState.connected) {
    } else {
      client = await _login();
      if (client == null) {
        return false;
      }
    }
    return true;
  }

  Future<MqttClient> _login() async {
    client = MqttServerClient.withPort(server, cID, port);
    // Turn on mqtt package's logging while in test.
    client.logging(on: false);
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(cID)
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
    /// never send malformed messages.
    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXCEPTION::client exception - $e');
      client.disconnect();
      client = null;
      return client;
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('Connected to the broker');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'Connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      client = null;
    }
    return client;
  }

  void _onDisconnected() {
    print("disconnected");
  }

  void _onConnected() {
    print("connected");
  }

  void _onSubscribed(String topic) {
    print("subscribed" + topic);
  }

//
// Subscribe to the topic.
//
  Future _subscribe(String topic, int qos) async {
    // for now hardcoding the topic
    if (!subscribedTopic.contains(topic)) {
      var isSubed = false;
      if (qos == 0) {
        client.subscribe(topic, MqttQos.atMostOnce);
        isSubed = true;
        print('Subscribing to the topic $topic');
      } else if (qos == 1) {
        client.subscribe(topic, MqttQos.atLeastOnce);
        isSubed = true;

        print('Subscribing to the topic $topic');
      } else if (qos == 2) {
        client.subscribe(topic, MqttQos.exactlyOnce);
        isSubed = true;
      } else {
        print("Invalid QoS");
      }

      if (isSubed) {
        print('Subscribing to the topic $topic');
        client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess = c[0].payload;
          final String pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          // TODO: Save pt to somewhere
          //
          /// The payload is a byte buffer, this will be specific to the topic
          print(
              'Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
          return pt;
        });
      }
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
  }

//////////////////////////////////////////
// Publish to a mqtt topic.
  Future<void> publish(String topic, String value, int qos) async {
    // Connect to the client if we haven't already
    if (await _connectToBroker() == true) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(value);
      if (qos == 0) {
        client.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
      } else if (qos == 1) {
        client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
      } else if (qos == 2) {
        client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
      } else {
        print("Invalid QoS");
      }
    }
  }
}
