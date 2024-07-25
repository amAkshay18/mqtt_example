import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MQTTService {
  final String serverUri = 'broker.mqtt.cool';
  final String clientId = const Uuid().v4();

  MqttServerClient? client;

  Future<void> connect() async {
    client = MqttServerClient(serverUri, clientId);
    client!.logging(on: true);
    client!.port = 1883;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
    } catch (e) {
      log('Exception: $e');
      disconnect();
    }
  }

  void onConnected() {
    debugPrint('Connected');
  }

  void onDisconnected() {
    debugPrint('Disconnected');
  }

  void disconnect() {
    client?.disconnect();
  }

  void publish(String topic, String message, int qosLevel) async {
    await connect();
    log('Publishing message to topic $topic with QoS $qosLevel');
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.values[qosLevel], builder.payload!);
  }
}
