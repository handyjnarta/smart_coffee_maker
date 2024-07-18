import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/utils.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'main.dart';

class BluetoothData {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the Bluetooth
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;

  // To track whether the device is still connected to Bluetooth
  bool? get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;
  bool _isConnectionLost = false;
  int _reconnectCounter = 0;
  Timer? _timer;

  BluetoothData._privateConst();

  static BluetoothData instance = BluetoothData._privateConst();
  factory BluetoothData() => instance;

  // Define some variables, which will be required later
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? device;

  // StreamController to send messages
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  Future<void> initBluetooth() async {
    // Get current state
    debugPrint('[bluetooth_data] reading bluetooth state');
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (bluetoothState == BluetoothState.STATE_ON) {
      ctrl.isBluetoothActive.value = true;
      debugPrint('[bluetooth_data] Bluetooth already active');
      ctrl.refreshLogs(text: 'Bluetooth already active');
      ctrl.refreshDeviceList();
    }

    enableBluetooth();

    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) async {
        bluetoothState = state;
        if (bluetoothState == BluetoothState.STATE_OFF) {
          ctrl.isBluetoothActive.value = false;
          ctrl.isConnected.value = false;
          ctrl.isConnecting.value = false;
          ctrl.refreshLogs(text: 'Bluetooth turned OFF');
        }
        else if (bluetoothState == BluetoothState.STATE_ON) {
          ctrl.isBluetoothActive.value = true;
          ctrl.refreshLogs(text: 'Bluetooth turned ON');
        }

        await getPairedDevices();
        ctrl.devIndex.value = 0;
        ctrl.refreshDeviceList();
        debugPrint('[bluetooth_data] onStateChanged: ${ctrl.isBluetoothActive.value}');
    });
  }

  void dispose() {
    if (isConnected!) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    _timer?.cancel();
    _messageController.close(); // Close the StreamController
  }

  void connect() async {
    if (device == null) {
      debugPrint('No device selected');
    } else {
      ctrl.refreshLogs(text: 'Connecting to ${ctrl.selectedDevice}');
      ctrl.isConnecting.value = true;
      startTimeoutConnectionTimer();

      if (!isConnected!) {
        await BluetoothConnection.toAddress(device?.address).then((conn) {
          debugPrint('Connected to the device');
          showGetxSnackbar('Connected', 'Connected to the device');

          connection = conn;
          ctrl.isConnected.value = true;
          ctrl.isConnecting.value = false;
          _timer?.cancel();
          _reconnectCounter = 0;
          _isConnectionLost = false;
          ctrl.refreshLogs(text: 'Connected');

          connection?.input?.listen((Uint8List data) {
            final dataString = ascii.decode(data, allowInvalid: true).trim();
            debugPrint('[bluetooth_data] Data incoming: $dataString');

            if (dataString.isNotEmpty) {
              ctrl.refreshLogs(sourceId: SourceId.clientId, text: dataString);
              _messageController.add(dataString); // Send the message to the stream
            }
          }).onDone(() {
            debugPrint('[bluetooth_data] on done');
            String status = '';

            if (isDisconnecting) {
              status = '[bluetooth_data] Disconnecting locally!';
              isDisconnecting = false;
              debugPrint(status);
            } else {
              status = '[bluetooth_data]Disconnected remotely or connection lost!';
              debugPrint(status);
              _isConnectionLost = true;
            }

            status = status.replaceAll('[bluetooth_data]', '');
            ctrl.refreshLogs(text: status);
            showGetxSnackbar('Disconnected', status);
            ctrl.isConnected.value = false;
            reConnect();
          });
        }).catchError((error) {
          debugPrint('[bluetooth_data] Cannot connect, exception occurred: $error');
          showGetxSnackbar('Failed to connect', 'Cannot connect, exception occurred');
          ctrl.refreshLogs(text:'Cannot connect');
          ctrl.isConnecting.value = false;
          _timer?.cancel();
          reConnect();
        });
      }
    }
  }

  void reConnect() {
    Future.delayed(const Duration(seconds: 15)).then((value) {
      if (ctrl.isAutoReconnect.isTrue && bluetoothState == BluetoothState.STATE_ON
          && _isConnectionLost && _reconnectCounter < maxTryReconnect)
      {
        _reconnectCounter++;
        debugPrint('[bluetooth_data] auto reconnect active, reconnecting #$_reconnectCounter/$maxTryReconnect');
        ctrl.refreshLogs(text: 'Auto reconnect active, reconnecting #$_reconnectCounter/$maxTryReconnect');
        showGetxSnackbar('Reconnecting', 'Trying to reconnect');
        BluetoothData.instance.connect();
      }
    });
  }

  Future<void> disconnect() async {
    await connection?.close();
    showGetxSnackbar('Disconnected', 'Device disconnected');
    ctrl.refreshLogs(text:'Device disconnected');
    debugPrint('Device disconnected');
    ctrl.isConnected.value = false;
  }

  Future<void> enableBluetooth() async {
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      debugPrint("Error");
    }

    devicesList = devices;
  }

  void startTimeoutConnectionTimer() {
    debugPrint('[bluetooth_data] start counting timeout...');
    int start = maxConnectionTimeOut;

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
        debugPrint('[bluetooth_data] time out in: $start');
        if (start == 0) {
          if (ctrl.isConnecting.isTrue) {
            debugPrint('[bluetooth_data] Connection timeout');
            showGetxSnackbar('Failed to connect', 'Connection time out');
            ctrl.refreshLogs(text: 'Failed to connect. Connection time out!', sourceId: SourceId.statusId);
            ctrl.isConnecting.value = false;
          }

          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }

  Future<void> sendMessageToBluetooth(String message, bool asSwitch) async {
    if (ctrl.isConnected.isTrue) {
      Uint8List data = utf8.encode("$message" "\r\n");
      connection?.output.add(data);
      await connection?.output.allSent;
    }
  }
}