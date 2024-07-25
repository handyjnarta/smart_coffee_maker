import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import '/services/firestore_service.dart';
import 'commands.dart';

class Devices {
  final String recipeName;
  String id;
  int setpoint;
  List<Commands> commandList;

  Devices({
    required this.id,
    required this.setpoint,
    required this.commandList,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "setpoint": setpoint,
        "commandList": commandList.map((cmd) => cmd.toJson()).toList(),
      };

  static Devices fromJson(Map<String, dynamic> json) => Devices(
        id: json["id"],
        setpoint: json["setpoint"],
        commandList: (json["commandList"] as List)
            .map((cmd) => Commands.fromJson(cmd))
            .toList(),
      );

  set setNewId(String new_id) => id = new_id;
  // set setNewCommandList(List<Commands> newCommandList) => commandList = newCommandList;
}

class DeviceManager {
  // Singleton
  DeviceManager._privateConst();
  static final DeviceManager instance = DeviceManager._privateConst();
  factory DeviceManager() => instance;

  final FirestoreService _firestoreService = FirestoreService();
  final List<bool> _setpointList = [];

  List<bool> get getStatusDeviceList => _setpointList;

  int get getDeviceCount => _setpointList.length;

  Future<void> saveDeviceListIntoFirestore(List<Devices> deviceList) async {
    await _firestoreService.saveDeviceListIntoFirestore(deviceList);
  }

  Future<List<Devices>> loadDeviceListFromFirestore() async {
    final allDevices = await _firestoreService.loadDeviceListFromFirestore();
    _setpointList.clear();
    for (final device in allDevices) {
      _setpointList.add(device.setpoint);
    }
    return allDevices;
  }
}
