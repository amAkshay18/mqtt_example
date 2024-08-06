import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class LightController extends StatefulWidget {
  const LightController({super.key});

  @override
  State<LightController> createState() => _LightControllerState();
}

class _LightControllerState extends State<LightController> {
  Map<String, dynamic> updatedPayloadMap = {};

  final String _username = 'Navin';
  final String _password = 'Navi@1405';
  final String productId = '4ltc225';

  //methods for subscription
  String getStatus(String productId) => 'onwords/$productId/currentStatus';
  String postStatusRequest(String productId) =>
      'onwords/$productId/getCurrentStatus';
  String postStatus(String productId) => 'onwords/$productId/status';

  late MqttServerClient client;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<bool> _connect() async {
    bool status = false;
    log("called local mqtt connection");

    client = MqttServerClient.withPort("mqtt.onwords.in", "Client Test", 1883);

    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
    client.onUnsubscribed = _onUnsubscribed;

    final connectMessage = MqttConnectMessage()
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withWillRetain();
    client.connectionMessage = connectMessage;

    try {
      if (client.connectionStatus!.state == MqttConnectionState.disconnected) {
        await client
            .connect(_username, _password)
            .timeout(const Duration(milliseconds: 1500));
      }
      if (isConnected) status = true;
    } catch (e) {
      log("Error in mqtt connection $e");
      client.disconnect();
    }

    return status;
  }

  bool get isConnected {
    bool connected = false;
    try {
      connected =
          client.connectionStatus!.state == MqttConnectionState.connected;
    } catch (e) {
      log('Error from MQTT status check $e');
    }
    return connected;
  }

  void disconnect() {
    client.disconnect();
  }

  Set<String> subscribedTopics = <String>{};

  void subscribe(String topic) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      if (!subscribedTopics.contains(topic)) {
        client.subscribe(topic, MqttQos.atLeastOnce);
      }
    }
  }

  void unSubscribe(String topic) async {
    if (subscribedTopics.contains(topic)) {
      client.unsubscribe(topic);
      subscribedTopics.remove(topic);
    }
  }

  void _onConnected() {
    log('MQTTClient::Connected');
    _getStatusOnConnected();
  }

  void _onDisconnected() {
    log('MQTTClient::Disconnected');
    subscribedTopics.clear();
  }

  void _onSubscribed(String topic) {
    subscribedTopics.add(topic);
    log('MQTTClient::Subscribed to topic: $topic all topics are $subscribedTopics');
  }

  void _onUnsubscribed(String? topic) {
    log('MQTTClient::Unsubscribed topic: $topic all topics are $subscribedTopics');
  }

  void _getStatusOnConnected() {
    log("start");

    // Subscribe to current status topic
    String currentStatusTopic = getStatus(productId);
    client.subscribe(currentStatusTopic, MqttQos.atMostOnce);

    // Subscribe to get current status request topic
    String getCurrentStatusRequestTopic = postStatusRequest(productId);
    client.subscribe(getCurrentStatusRequestTopic, MqttQos.atMostOnce);

    // Subscribe to status topic
    String statusTopic = postStatus(productId);
    client.subscribe(statusTopic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final MqttPublishMessage receivedMessage =
          c![0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
          receivedMessage.payload.message);
      log("Received message: $payload from topic ${c[0].topic}");

      setState(() {
        payload == 'ON';
      });
    });
    log("Connected to Broker");
  }

  void publishStatus() {
    final topic = postStatus(productId);
    final builder = MqttClientPayloadBuilder();

    // Convert the updated payload map to a JSON string
    final payloadJson = jsonEncode(updatedPayloadMap);

    // Add the payload to the builder
    builder.addString(payloadJson);

    // Publish the message with the updated payload
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);

    log('Published payload: $payloadJson');
  }

  // void publishMessage(String deviceIdentifier, String message) {
  //   if (client.connectionStatus?.state == MqttConnectionState.connected) {
  //     final topic = postStatus(productId);
  //     final builder = MqttClientPayloadBuilder();
  //     builder.addString(message);
  //     client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  //     log('MQTT PUBLISHED MESSAGE TO $topic WITH DATA $message');
  //   } else {
  //     log('MQTT client is not connected. Cannot publish message.');
  //   }
  // }

  Color getColorForValue(dynamic value) {
    if (value == 1) {
      return Colors.yellowAccent;
    } else if (value == 0) {
      return Colors.grey;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Light Controller"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<List<MqttReceivedMessage<MqttMessage>>>(
              stream: client.updates,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final receivedMessages = snapshot.data ?? [];
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 1,
                    width: MediaQuery.of(context).size.width * 1,
                    child: ListView.builder(
                      itemCount: receivedMessages.length,
                      itemBuilder: (context, index) {
                        final MqttPublishMessage receivedMessage =
                            receivedMessages[index].payload
                                as MqttPublishMessage;
                        final Map<String, dynamic> payloadMap = jsonDecode(
                            MqttPublishPayload.bytesToStringAsString(
                                receivedMessage.payload.message));
                        updatedPayloadMap = payloadMap;
                        List<Widget> listTiles = [];

                        // Function to get the trailing icon based on device type and status
                        Widget getTrailingIcon(
                            String deviceType, int statusValue) {
                          IconData iconData;
                          Color color;

                          switch (deviceType) {
                            case 'device5':
                            case 'device6':
                              iconData = Icons.ac_unit;
                              color = (statusValue == 1)
                                  ? Colors.blueAccent
                                  : Colors.grey;
                              break;
                            default:
                              iconData = Icons
                                  .lightbulb_circle; // Change to appropriate default icon
                              color = (statusValue == 1)
                                  ? Colors.yellow
                                  : Colors.red;
                              break;
                          }

                          return GestureDetector(
                            onTap: () {
                              // Update the value when the trailing icon is clicked
                              setState(() {
                                if (updatedPayloadMap.containsKey(deviceType)) {
                                  updatedPayloadMap[deviceType] =
                                      (statusValue == 1) ? 0 : 1;
                                } else {
                                  updatedPayloadMap[deviceType] =
                                      (statusValue == 1) ? 0 : 1;
                                }
                                log(updatedPayloadMap as String);
                                publishStatus();
                              });
                            },
                            child: Icon(
                              iconData,
                              color: color,
                            ),
                          );
                        }

                        // Iterate through devices
                        payloadMap.forEach((key, value) {
                          if (key.startsWith('device') &&
                              key != 'device5' &&
                              key != 'device6') {
                            final deviceTile = ListTile(
                              title: Text(key),
                              subtitle: Text('Status: $value'),
                              trailing: getTrailingIcon(key, value),
                            );
                            listTiles.add(Card(child: deviceTile));
                          }
                        });

                        // Check for speed data associated with device5
                        if (payloadMap.containsKey('speed')) {
                          final speedValue = payloadMap['speed'];
                          final statusValue = payloadMap[
                              'device5']; // Assuming 'device5' holds status
                          final device5Tile = ListTile(
                            title: const Text('device5'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: $statusValue'),
                                Text('Speed: $speedValue'),
                              ],
                            ),
                            trailing: getTrailingIcon('device5', statusValue),
                          );
                          listTiles.add(Card(child: device5Tile));
                        } else {
                          // If speed data is missing for device5, add an empty card
                          listTiles.add(
                            Card(
                              child: ListTile(
                                title: const Text('device5'),
                                subtitle: const Text('No speed data'),
                                trailing: getTrailingIcon('device5', 0),
                              ),
                            ),
                          );
                        }

                        // Check for speed_1 data associated with device6
                        if (payloadMap.containsKey('speed_1')) {
                          final speed1Value = payloadMap['speed_1'];
                          final status1Value = payloadMap[
                              'device6']; // Assuming 'device6' holds status
                          final device6Tile = ListTile(
                            title: const Text('device6'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: $status1Value'),
                                Text('Speed_1: $speed1Value'),
                              ],
                            ),
                            trailing: getTrailingIcon('device6', status1Value),
                          );
                          listTiles.add(Card(child: device6Tile));
                        } else {
                          // If speed_1 data is missing for device6, add an empty card
                          listTiles.add(
                            Card(
                              child: ListTile(
                                title: const Text('Device6'),
                                subtitle: const Text('No speed_1 data'),
                                trailing: getTrailingIcon('device6', 0),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: listTiles,
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
