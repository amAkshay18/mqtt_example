import 'package:flutter/material.dart';
import 'package:onwords/features/home/service/mqtt_services.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.mqttService});
  final MQTTService mqttService;
  String selectedQoS = '0';

  final TextEditingController topicController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  void publish(
      {required String topic, required String message, required int qosLevel}) {
    mqttService.publish(topic, message, qosLevel);
  }

  Future<void> connect() async {
    await mqttService.connect();
  }

  updateSelectedQOS(String qos) {
    selectedQoS = qos;
    notifyListeners();
  }

  void clearTextFields() {
    topicController.clear();
    messageController.clear();
  }
}
