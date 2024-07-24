import 'package:flutter/material.dart';
import 'package:onwords/features/home/service/mqtt_services.dart';
import 'package:onwords/features/home/view/home_screen.dart';
import 'package:onwords/features/home/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(mqttService: MQTTService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HomeScreen',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
