import 'dart:developer';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MQTTService {
  // broker selection
  final String serverUri = 'broker.mqtt.cool';
  final String clientId = const Uuid().v4();
  //----------selecting sambavam
  final String topic = '123456';

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
    print('Connected');
    subscribe();
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void disconnect() {
    client?.disconnect();
  }

  void subscribe() {
    client!.subscribe(topic, MqttQos.atMostOnce);
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Received message: $pt from topic: ${c[0].topic}>');
    });
  }

  void publish(String message) async {
    await connect(); // Connect to the MQTT server
    log('message');
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }
}
