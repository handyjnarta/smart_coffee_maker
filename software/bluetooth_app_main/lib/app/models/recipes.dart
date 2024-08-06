import '/services/firestore_service.dart';
import 'commands.dart';

class Devices {
  String deviceName;
  bool status;
  List<Commands> commandList;

  Devices({
    required this.deviceName,
    required this.status,
    required this.commandList,
  });

  Map<String, dynamic> toJson() => {
        "deviceName": deviceName,
        "status": status,
        "commandList": commandList.map((cmd) => cmd.toJson()).toList(),
      };

  static Devices fromJson(Map<String, dynamic> json) => Devices(
        deviceName: json["deviceName"],
        status: json["status"],
        commandList: (json["commandList"] as List)
            .map((cmd) => Commands.fromJson(cmd))
            .toList(),
      );

  set setNewDeviceName(String newDeviceName) => deviceName = newDeviceName;
  // set setNewCommandList(List<Commands> newCommandList) => commandList = newCommandList;
}

class DeviceManager {
  // Singleton
  DeviceManager._privateConst();
  static final DeviceManager instance = DeviceManager._privateConst();
  factory DeviceManager() => instance;

  final FirestoreService _firestoreService = FirestoreService();
  final List<bool> _statusList = [];

  List<bool> get getStatusDeviceList => _statusList;

  int get getDeviceCount => _statusList.length;

  Future<void> saveDeviceListIntoFirestore(List<Devices> deviceList) async {
    await _firestoreService.saveDeviceListIntoFirestore(deviceList);
  }

  Future<List<Devices>> loadDeviceListFromFirestore() async {
    final allDevices = await _firestoreService.loadDeviceListFromFirestore();
    _statusList.clear();
    for (final device in allDevices) {
      _statusList.add(device.status);
    }
    return allDevices;
  }
}
