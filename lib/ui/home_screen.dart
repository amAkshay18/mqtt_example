import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:onwords/mqtt_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MQTTService mqttService = MQTTService();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedQoS = '0'; // Default QoS

  @override
  void dispose() {
    topicController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: 'Create Topic',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Enter Message',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedQoS,
                items: <String>['0', '1', '2'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Quality of Service(QOS)$value'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedQoS = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double
                    .infinity, // Make the button the same width as the parent
                child: ElevatedButton(
                  onPressed: () async {
                    await mqttService.connect();
                    log('Connected to MQTT server');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connected to MQTT server'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Connect'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double
                    .infinity, // Make the button the same width as the parent
                child: ElevatedButton(
                  onPressed: () {
                    if (topicController.text.isNotEmpty &&
                        messageController.text.isNotEmpty) {
                      mqttService.publish(
                        topicController.text,
                        messageController.text,
                        int.parse(selectedQoS),
                      );
                      log('Message published');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message published'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter both topic and message'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Publish Message'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
