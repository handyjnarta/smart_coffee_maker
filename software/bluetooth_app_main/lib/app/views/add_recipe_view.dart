import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
import 'package:flutter_bluetooth/app/views/add_command_view.dart';
import 'package:get/get.dart';
import '../controllers/command_controller.dart';
import '../helper/widget_helper.dart';
import '../helper/popup_dialogs.dart';

class AddDeviceView extends StatelessWidget {
  final String title;

  const AddDeviceView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 250),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.deepPurple,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField(
                        title: 'Recipe Name',
                        commandText: DeviceController.deviceNameController.text,
                        errorText: DeviceController.errorText.value,
                        commandTextController:
                            DeviceController.deviceNameController,
                        onChanged: (value) {
                          DeviceController.refreshNewCommandButtonState();
                        },
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 14.0),
                            child: Text(
                              'Commands:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const Expanded(child: SizedBox(width: 20)),
                          OutlinedButton(
                            onPressed: () {
                              if (DeviceController.enableNewCommandBtn.isTrue) {
                                createNewCommand(context);
                              } else {
                                final deviceName = int.tryParse(
                                    DeviceController.deviceNameController.text);
                                if (deviceName == null ||
                                    deviceName < 30 ||
                                    deviceName > 95) {
                                  DeviceController.errorText.value =
                                      'Suhu harus diantara 30 dan 95';
                                } else {
                                  DeviceController.errorText.value =
                                      'Max command is $maxCommandCount';
                                }
                              }
                            },
                            style: buildButtonStyle(
                                borderColor: Colors.grey, buttonWidth: 80),
                            child: const Text('New Command'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(thickness: 2),
                      const SizedBox(height: 10),
                      saveButton(context),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String title,
    required String commandText,
    required String errorText,
    required TextEditingController commandTextController,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        TextField(
          controller: commandTextController,
          onChanged: onChanged,
          decoration: InputDecoration(
            errorText: errorText.isEmpty ? null : errorText,
          ),
        ),
      ],
    );
  }

  Widget saveButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          if (DeviceController.currentDevice == null ||
              DeviceController.currentDevice!.commandList.length <
                  minCommandCount) {
            showCustomDialog(
              context: context,
              actionList: standardPopupItems(
                  contentText:
                      'Please add at least $minCommandCount command(s)'),
              title: 'Command < $minCommandCount',
            );
          } else {
            DeviceController.refreshSaveDeviceButtonState();
            if (DeviceController.enableSaveDeviceBtn.isTrue) {
              DeviceController.saveDeviceData();
              Navigator.of(context).pop();
            }
          }
        },
        style: buildButtonStyle(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save),
            SizedBox(width: 10),
            Text('Save Recipe'),
          ],
        ),
      ),
    );
  }

  void createNewCommand(BuildContext context) {
    DeviceController.onNewCommandButtonPressed();
    showCustomDialog(
      context: context,
      actionList: [const CommandView()],
      title: 'Create New Command',
    );
  }

  static void editCommand(BuildContext buildContext) {}
}
