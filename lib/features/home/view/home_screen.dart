import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:onwords/features/home/view_model/home_view_model.dart';
import 'package:onwords/utils/app_strings.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    context.read<HomeViewModel>().topicController.dispose();
    context.read<HomeViewModel>().messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: context.read<HomeViewModel>().topicController,
                decoration: const InputDecoration(
                  labelText: 'Create Topic',
                ),
              ),
              const SizedBox(height: 20),
              Selector<HomeViewModel, String>(
                  selector: (p0, p1) => p1.selectedQoS,
                  builder: (context, selectedQos, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: selectedQos,
                        isExpanded: true,
                        underline: Container(
                          height: 2,
                          color: Colors.blueAccent,
                        ),
                        items: <String>['0', '1', '2'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              'Quality of Service(QOS)$value',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          context
                              .read<HomeViewModel>()
                              .updateSelectedQOS(newValue ?? "0");
                        },
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
              const SizedBox(height: 20),
              TextFormField(
                controller: context.read<HomeViewModel>().messageController,
                decoration: const InputDecoration(
                  labelText: 'Enter Message',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<HomeViewModel>().connect().whenComplete(
                      () {
                        log('Connected to MQTT server');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connected to MQTT server'),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(AppStrings.connect),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final topic =
                        context.read<HomeViewModel>().topicController.text;
                    debugPrint(
                        '----------------------------------------$topic');

                    final message =
                        context.read<HomeViewModel>().messageController.text;
                    debugPrint(
                        '----------------------------------------$message');
                    final selectedQualityOfService =
                        int.parse(context.read<HomeViewModel>().selectedQoS);
                    if (topic.isNotEmpty && message.isNotEmpty) {
                      context.read<HomeViewModel>().publish(
                            message: message,
                            qosLevel: selectedQualityOfService,
                            topic: topic,
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
                  //-----------------------------------------------------------------------------------
                  child: const Text(AppStrings.publish),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
