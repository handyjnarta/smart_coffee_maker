import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BluetoothConnection _connection;
  bool _isConnecting = true;
  bool _connected = false;
  List<String> _devicesList = ['Device 1']; // Replace with actual device names
  String? _device;
  bool _isButtonUnavailable = false;
  List<Map<String, String>> _messages = [];
  int _currentStep = 0;

  final TextEditingController _controller = TextEditingController();
  Map<String, String> _answers = {};
  int _totalSessions = 0;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  void _initBluetooth() async {
    BluetoothDevice? device = await _getDevice();
    if (device == null) {
      print('No device selected');
      return;
    }
    _connectToDevice(device);
  }

  Future<BluetoothDevice?> _getDevice() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (ex) {
      print('Error getting bonded devices: $ex');
    }

    if (devices.isEmpty) {
      show('No bonded devices found');
      return null;
    }

    return devices.firstWhere((device) =>
        device.name ==
        'Device 1'); // Replace 'Device 1' with your actual device name
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _isConnecting = false;
        _connected = true;
        show('Connected to ${device.name}');
        _messages
            .add({"sender": "app", "message": "Connected to ${device.name}"});
      });

      _connection.input?.listen((Uint8List data) {
        // Handle incoming data from the device
        String message = utf8.decode(data);
        setState(() {
          _messages.add({"sender": "device", "message": message});
        });
      }).onDone(() {
        // Handle device disconnection
        setState(() {
          _connected = false;
          show('Device disconnected');
          _messages.add(
              {"sender": "app", "message": "Disconnected from ${device.name}"});
        });
      });
    } catch (ex) {
      print('Error connecting to device: $ex');
    }
  }

  void _sendMessage(String message) async {
    if (_connection.isConnected) {
      _connection.output.add(utf8.encode(message + "\r\n"));
      await _connection.output.allSent;
      setState(() {
        _messages.add({"sender": "user", "message": message});
      });
    } else {
      show('Not connected to device');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Flutter Bluetooth"),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            label: Text(
              "Refresh",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashFactory: InkSplash.splashFactory,
            ),
            onPressed: () {
              show('Device list refreshed');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Enable Bluetooth',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (bool value) {
                    setState(() {});
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Device:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  items: _getDeviceItems(),
                  onChanged: (value) => setState(() => _device = value),
                  value: _devicesList.isNotEmpty ? _device : null,
                ),
                ElevatedButton(
                  onPressed: _isButtonUnavailable
                      ? null
                      : _connected
                          ? _disconnect
                          : _initBluetooth,
                  child: Text(_connected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageTile(_messages[index]);
              },
            ),
          ),
          if (_connected && _currentStep < _getQuestions().length)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: _getQuestions()[_currentStep],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          if (_currentStep == _getQuestions().length)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total water = ${_calculateTotalWater()} and total session = ${_calculateTotalSession()} minutes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDeviceItems() {
    List<DropdownMenuItem<String>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device),
          value: device,
        ));
      });
    }
    return items;
  }

  void _disconnect() async {
    await _connection.close();
    setState(() {
      _connected = false;
      show('Disconnected from device');
      _messages.add({"sender": "app", "message": "Disconnected from Device 1"});
    });
  }

  List<String> _getQuestions() {
    List<String> questions = ["desired temperature", "total session"];
    if (_answers.containsKey("total session")) {
      _totalSessions = int.parse(_answers["total session"]!);
      for (int i = 1; i <= _totalSessions; i++) {
        questions.add("how much water for session $i");
        questions.add("how long it will be done for session $i");
        questions.add("how long the delay for session $i");
      }
    }
    return questions;
  }

  String _calculateTotalWater() {
    int totalWater = 0;
    for (int i = 1; i <= _totalSessions; i++) {
      totalWater += int.parse(
          _answers["how much water for session $i"]!.replaceAll("mL", ""));
    }
    return "$totalWater mL";
  }

  String _calculateTotalSession() {
    int totalSession = 0;
    for (int i = 1; i <= _totalSessions; i++) {
      totalSession +=
          int.parse(_answers["how long it will be done for session $i"]!) +
              int.parse(_answers["how long the delay for session $i"]!);
    }
    return "$totalSession";
  }

  Widget _buildMessageTile(Map<String, String> message) {
    bool isUser = message["sender"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.green[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message["message"]!,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(Duration(milliseconds: 100));
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
