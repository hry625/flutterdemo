import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:sensors/sensors.dart';

import 'flutter_mqtt_client.dart';

class RaceMode extends StatefulWidget {
  RaceMode({Key key}) : super(key: key);

  @override
  _RaceModeState createState() => _RaceModeState();
}

class _RaceModeState extends State<RaceMode> {
  MqttServerClient client;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text('Connect'),
                    onPressed: () => {
                      connect().then((value) {
                        client = value;
                        client.subscribe(
                            '/smartcar/group3/camera', MqttQos.atLeastOnce);
                      })
                    },
                  ),
                  TextButton(onPressed: onConnected, child: Text('Break'))
                ],
              ),
              flex: 2,
            ),
            Flexible(
              child: Container(
                color: Colors.blue,
              ),
              flex: 2,
            ),
            Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: onConnected, child: Text('Pause')),
                    TextButton(onPressed: onConnected, child: Text('Throttle')),
                  ],
                ),
                flex: 8),
            // Text('gyro x' + _gyroscopeValues[0].toStringAsFixed(4)),
            // Spacer(),
            // Text('gyro y' + _gyroscopeValues[1].toStringAsFixed(4)),

            // Spacer(),
            // Text('gyro z' + _gyroscopeValues[2].toStringAsFixed(4)),
          ]),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
