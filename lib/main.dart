import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:onwords/mqtt_services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MQTTService mqttService = MQTTService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MQTT Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  await mqttService.connect();
                  log('Connected to MQTT server');
                },
                child: const Text('Connect'),
              ),
              ElevatedButton(
                onPressed: () {
                  //message..........
                  mqttService.publish('onwords');
                  log('message published');
                },
                child: const Text('Publish Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
