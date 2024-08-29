import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import '../../bluetooth_data.dart';
import '../../main.dart';
import '../../utils.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 229, 180), // Background Utama
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Obx(() {
            return Visibility(
              visible: ctrl.isConnecting.value,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.yellow,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          }),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Obx(() {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Switch(
                              activeColor: const Color.fromARGB(255, 140, 100, 60),
                              activeTrackColor: const Color.fromARGB(255, 220, 180, 120),
                              inactiveThumbColor: const Color.fromARGB(255, 140, 100, 60),
                              inactiveTrackColor: const Color.fromARGB(255, 220, 180, 120),
                              value: ctrl.isBluetoothActive.value,
                              onChanged: (bool value) async {
                                if (value) {
                                  await FlutterBluetoothSerial.instance.requestEnable();
                                  await BluetoothData.instance.getPairedDevices();
                                } else {
                                  if (ctrl.isConnected.isTrue) {
                                    BluetoothData.instance.disconnect();
                                  }
                                  await FlutterBluetoothSerial.instance.requestDisable();
                                }
                              },
                            ),
                            const SizedBox(width: 4,),
                            const Text(
                              'Enable Bluetooth',
                              style: TextStyle(
                                color: Color.fromARGB(255, 60, 42, 33), // Teks Utama
                                fontSize: 16,
                              ),
                            ),
                            const Expanded(child: SizedBox()),

                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  (ctrl.selectedDevice.value != 'NONE' &&
                                      ctrl.selectedDevice.value != '' &&
                                      ctrl.isConnecting.isFalse &&
                                      ctrl.isBluetoothActive.isTrue)
                                      ? const Color.fromARGB(255, 189, 146, 102) // Tombol Aktif
                                      : const Color.fromARGB(255, 255, 204, 153) // Tombol Tidak Aktif
                                ),
                              ),
                              onPressed: () {
                                onPressedConnectButton();
                              },
                              child: Text(
                                _getButtonText(),
                                style: TextStyle(
                                  color: _getButtonTextColor(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Switch(
                              activeColor: const Color.fromARGB(255, 140, 100, 60),
                              activeTrackColor: const Color.fromARGB(255, 220, 180, 120),
                              inactiveThumbColor: const Color.fromARGB(255, 140, 100, 60),
                              inactiveTrackColor: const Color.fromARGB(255, 220, 180, 120),
                              value: ctrl.isAutoReconnect.value,
                              onChanged: (bool newVal) {
                                ctrl.isAutoReconnect.value = newVal;
                              }
                            ),
                            const SizedBox(width: 2,),
                            const Text('Auto reconnect if connection lost',
                              style: TextStyle(
                                color: Color.fromARGB(255, 60, 42, 33), // Teks Utama
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  const Divider(thickness: 1.0,),
                  const SizedBox(height: 15,),
                  const Text(
                    "Paired Devices",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 60, 42, 33), // Teks Utama
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Obx(() {
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Device:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 60, 42, 33), // Teks Utama
                              ),
                            ),
                            buildDeviceDropDown(),
                          ],
                        ),
                        const Divider(thickness: 1.0,),
                        const SizedBox(height: 10,),
                        refreshButton(),
                        const Divider(thickness: 1.0,),
                        const SizedBox(height: 10,),
                      ],
                    );
                  }),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                child: const Text("Bluetooth Settings"),
                                onPressed: () {
                                  FlutterBluetoothSerial.instance.openSettings();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getButtonText() {
    return ctrl.isConnected.isTrue
      ? 'Disconnect'
      : ctrl.isConnecting.isTrue
        ? 'Connecting'
        : 'Connect';
  }

  Color _getButtonTextColor() {
    return ctrl.isConnected.isTrue
      ? Colors.white // White text for 'Disconnect'
      : ctrl.isConnecting.isTrue
        ? Color.fromARGB(255, 159, 104, 2) // Yellow text for 'Connecting'
        : Colors.black; // Black text for 'Connect'
  }

  refreshButton() {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.refresh,
        color: Colors.white,
      ),
      label: const Text(
        'Refresh',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          ctrl.isBluetoothActive.value
            ? Color.fromARGB(255, 50, 50, 50)
            : const Color.fromARGB(185, 148, 148, 148),
        ),
        fixedSize: WidgetStateProperty.all(const Size(200, 50)),
      ),
      onPressed: () async {
        if (ctrl.isBluetoothActive.value) {
          await BluetoothData.instance.getPairedDevices().then((_) {
            showGetxSnackbar('Devices refreshed', 'Device list refreshed');
            ctrl.refreshDeviceList();
            ctrl.refreshLogs(text: 'Device list refreshed');
          });
        }
      },
    );
  }

  buildDeviceDropDown() {
    var devList = ctrl.deviceItems.value.map<DropdownMenuItem<BluetoothDevice>>((dev) {
      return DropdownMenuItem(value: dev, child: Text(dev.name!));
    }).toList();

    return DropdownButton(
      menuMaxHeight: 200,
      items: devList,
      onChanged: (value) {
        if (value != null && value.name != 'NONE') {
          BluetoothData.instance.device = value;
          ctrl.devIndex.value = ctrl.deviceItems.value.indexWhere((element) {
            return element.name == value.name;
          });
        }

        ctrl.selectedDevice.value = value?.name ?? 'NONE';
      },
      value: ctrl.deviceItems.value[ctrl.devIndex.value],
    );
  }

  void onPressedConnectButton() {
    if (ctrl.isBluetoothActive.isFalse || ctrl.isConnecting.isTrue) {
      return;
    }
    if (ctrl.selectedDevice.value != '' && ctrl.selectedDevice.value != 'NONE') {
      if (ctrl.isConnecting.isFalse) {
        if (ctrl.isConnected.isTrue) {
          BluetoothData.instance.isDisconnecting = true;
          BluetoothData.instance.disconnect();
        } else {
          debugPrint('[connection_view] connecting...');
          BluetoothData.instance.connect();
        }
      }
    }
  }
}
