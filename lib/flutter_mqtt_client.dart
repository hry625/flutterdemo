import 'dart:typed_data';
import 'dart:ui';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';

Future<MqttClient> connect() async {
  // MqttServerClient client = MqttServerClient('127.0.0.1', 'group3');
  MqttServerClient client = MqttServerClient('aerostun.dev', 'group3');

  client.setProtocolV311();
  client.logging(on: true);
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onUnsubscribed = onUnsubscribed;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('group3')
      .keepAliveFor(60)
      .withWillTopic('willtopic')
      .withWillMessage('My Will message')
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;
  try {
    print('Connecting');
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus.state == MqttConnectionState.connected) {
    print('EMQX client connected');
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      if (c[0].topic == '/smartcar/group3/camera') {
        // final Bitmap bm = Bitmap.createBitmap(IMAGE_WIDTH, IMAGE_HEIGHT, Bitmap.Config.ARGB_8888);

        //                 final byte[] payload = message.getPayload();
        //                 final int[] colors = new int[IMAGE_WIDTH * IMAGE_HEIGHT];
        //                 for (int ci = 0; ci < colors.length; ++ci) {
        //                     final byte r = payload[3 * ci];
        //                     final byte g = payload[3 * ci + 1];
        //                     final byte b = payload[3 * ci + 2];
        //                     colors[ci] = Color.rgb(r, g, b);
        //                 }
        //                 bm.setPixels(colors, 0, IMAGE_WIDTH, 0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);

        //                 mCameraView.setImageBitmap(bm);
        //
        Uint8List picData = message.payload.message as Uint8List;
        // var colors = Uint8List(320*240);
        // for (var i = 0; i < picData.length; i++) {
        //   int r = picData[3 * i];
        //   int g = picData[3 * i + 1];
        //   int b = picData[3 * i + 2];
        //   colors[i]= Color.fromARGB(255, r, g, b);
        // }

        Bitmap bm = Bitmap.fromHeadless(320, 240, picData);
      } else {
        print('Received message:$payload from topic: ${c[0].topic}>');
      }
    });

    client.published.listen((MqttPublishMessage message) {
      print('published');
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print(
          'Published message: $payload to topic: ${message.variableHeader.topicName}');
    });
  } else {
    print(
        'EMQX client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }

  return client;
}

void onConnected() {
  print('Connected');
}

void onDisconnected() {
  print('Disconnected');
}

void onSubscribed(String topic) {
  print('Subscribed topic: $topic');
}

void onSubscribeFail(String topic) {
  print('Failed to subscribe topic: $topic');
}

void onUnsubscribed(String topic) {
  print('Unsubscribed topic: $topic');
}

void pong() {
  print('Ping response client callback invoked');
}
