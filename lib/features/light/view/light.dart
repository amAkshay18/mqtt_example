import 'package:flutter/material.dart';

class LightPage extends StatefulWidget {
  const LightPage({super.key});

  @override
  LightPageState createState() => LightPageState();
}

class LightPageState extends State<LightPage> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Bulb'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 100,
              color: _isOn ? Colors.yellow : Colors.grey,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isOn = !_isOn;
                });
              },
              child: Text(_isOn ? 'Turn Off' : 'Turn On'),
            ),
          ],
        ),
      ),
    );
  }
}
