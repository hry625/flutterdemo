import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_buddy_demo/flutter_mqtt_client.dart';
import 'package:smart_buddy_demo/mqttclientconnection.dart';

class Controlpanel extends StatefulWidget {
  Controlpanel({Key key}) : super(key: key);

  @override
  _ControlpanelState createState() => _ControlpanelState();
}

class _ControlpanelState extends State<Controlpanel> {
  // MqttClientConnection connection =
  //     MqttClientConnection("aerostun.dev", "group3App", 1883);
  MqttServerClient client;

  void onPressed() {}
  void _backward() {
    _throttle('-60');
  }

  void _forward() {
    _throttle('60');
  }

  void _throttle(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client?.publishMessage('/smartcar/group3/control/throttle',
        MqttQos.atLeastOnce, builder.payload);
  }

  void _steer(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client?.publishMessage(
        '/smartcar/control/steering', MqttQos.atLeastOnce, builder.payload);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: TextButton(
                child: Text('Connect'),
                onPressed: () => {
                  connect().then((value) {
                    client = value;
                  })
                },
              )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child:
                      TextButton(onPressed: _forward, child: Text("forward")),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  child: TextButton(onPressed: onPressed, child: Text("left")),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: TextButton(onPressed: onPressed, child: Text("right")),
                ),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              flex: 1,
              child: Container(),
            ),
            Flexible(
              flex: 1,
              child: Container(
                child:
                    TextButton(onPressed: _backward, child: Text("backward")),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(),
            ),
          ]),
        ],
      ),
    );
  }
}
