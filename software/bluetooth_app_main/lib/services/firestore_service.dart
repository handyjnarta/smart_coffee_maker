import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/models/devices.dart'; // Ensure you have the correct import path for your Devices class
import '../../app/models/commands.dart'; // Ensure you have the correct import path for your Commands class

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveDeviceListIntoFirestore(List<Devices> deviceList) async {
    for (final device in deviceList) {
      final deviceData = {
        'deviceName': device.deviceName,
        'status': device.status,
        'commandList': device.commandList.map((cmd) => cmd.toJson()).toList(),
      };
      await _db.collection('devices').doc(device.deviceName).set(deviceData);
    }
  }

  Future<List<Devices>> loadDeviceListFromFirestore() async {
    final querySnapshot = await _db.collection('devices').get();
    List<Devices> allDevices = [];
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      List<Commands> commandList = (data['commandList'] as List)
          .map((cmdData) => Commands.fromJson(cmdData))
          .toList();
      allDevices.add(Devices(
        deviceName: data['deviceName'],
        status: data['status'],
        commandList: commandList,
      ));
    }
    return allDevices;
  }
}
