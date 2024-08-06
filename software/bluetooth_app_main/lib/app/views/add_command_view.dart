import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:flutter_bluetooth/app/views/add_pouring_view.dart';
import 'package:get/get.dart';
import '../controllers/command_controller.dart';
import '../custom_widget/custom_button.dart';
import '../helper/widget_helper.dart';

class CommandController extends GetxController {
  static var commandTitleCtrl = TextEditingController();
  static var commandTitleErrorText = ''.obs;
  static var commandCtrl = TextEditingController();
  static var commandErrorText = ''.obs;
  static var isEditCommand = false.obs;
  static var isInputCommandValid = false.obs;

  static var stepsCount = 0.obs; // Jumlah langkah pouring
  static var currentStep = 0.obs; // Langkah pouring saat ini

  static void validateCommandInput(String value) {
    // Logika validasi
    isInputCommandValid.value = true; // Sederhana: asumsikan input valid
  }

  static void saveNewCommand() {
    // Logika untuk menyimpan perintah baru
  }

  static void resetSteps() {
    stepsCount.value = 0;
    currentStep.value = 0;
  }
}

class CommandView extends StatelessWidget {
  const CommandView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: commandItems(context),
    );
  }

  List<Widget> commandItems(BuildContext context) {
    List<Widget> actionList = [
      const SizedBox(height: 10),
      Obx(() {
        return buildTextField(
          title: 'Setpoint',
          commandText: CommandController.commandTitleCtrl.text,
          errorText: CommandController.commandTitleErrorText.value,
          commandTextController: CommandController.commandTitleCtrl,
          //onChanged: CommandController.validateCommandInput,
        );
      }),
      Obx(() {
        return SizedBox(
            height: CommandController.commandTitleErrorText.isEmpty ? 0 : 20);
      }),
      Obx(() {
        return Column(
          children: [
            buildTextField(
              title: 'Pouring Steps',
              commandText: CommandController.commandCtrl.text,
              errorText: CommandController.commandErrorText.value,
              commandTextController: CommandController.commandCtrl,
              //onChanged: CommandController.validateCommandInput,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                CommandController.stepsCount.value =
                    int.parse(CommandController.commandCtrl.text);
                CommandController.currentStep.value = 1;
                showPouringDialog(context);
              },
              child: const Text('Next'),
            ),
          ],
        );
      }),
      Obx(() {
        return SizedBox(
            height: CommandController.commandErrorText.isEmpty ? 0 : 20);
      }),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: MyCustomButton(
              customWidget: const Text('Cancel'),
              isCircleButton: false,
              buttonWidth: 100,
              onPressedAction: () {
                CommandController.isEditCommand.value = false;
                CommandController.resetSteps();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: MyCustomButton(
              customWidget: const Text('Save'),
              isCircleButton: false,
              buttonWidth: 100,
              onPressedAction: () {
                CommandController.validateCommandInput(
                    CommandController.commandCtrl.text);

                if (CommandController.isInputCommandValid.isTrue) {
                  CommandController.saveNewCommand();
                  DeviceController.refreshNewCommandButtonState();

                  if (CommandController.isEditCommand.isTrue) {
                    CommandController.isEditCommand.value = false;
                  }
                  CommandController.resetSteps();
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      )
    ];

    return actionList;
  }
}

void showPouringDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Obx(() {
          return Text('Pouring Step ${CommandController.currentStep.value}');
        }),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextField(
              title: 'Total Water',
              commandText: '', // Inisialisasi dengan nilai kosong atau yang ada
              errorText: '', // Tangani error jika ada
              commandTextController: TextEditingController(),
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Pouring Time',
              commandText: '', // Inisialisasi dengan nilai kosong atau yang ada
              errorText: '', // Tangani error jika ada
              commandTextController: TextEditingController(),
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Delay Time',
              commandText: '', // Inisialisasi dengan nilai kosong atau yang ada
              errorText: '', // Tangani error jika ada
              commandTextController: TextEditingController(),
              //onChanged: (value) {},
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CommandController.resetSteps();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (CommandController.currentStep.value <
                  CommandController.stepsCount.value) {
                CommandController.currentStep.value++;
                Navigator.pop(context);
                showPouringDialog(
                    context); // Menampilkan dialog untuk langkah berikutnya
              } else {
                Navigator.pop(context);
                CommandController.resetSteps();
              }
            },
            child: const Text('Next'),
          ),
        ],
      );
    },
  );
}


/*
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
} */

/*
class CommandView extends StatelessWidget {
  const CommandView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: commandItems(context),
    );
  }

  List<Widget> commandItems(BuildContext context) {
    List<Widget> actionList = [
      const SizedBox(height: 10),
      Obx(() {
        return buildTextField(
            title: 'Setpoint', //Command Title
            commandText: CommandController.commandTitleCtrl.text,
            errorText: CommandController.commandTitleErrorText.value,
            commandTextController: CommandController.commandTitleCtrl,
            onChanged: CommandController.validateCommmandInput
        );
      }),
      Obx(() {
        return SizedBox(height: CommandController.commandTitleErrorText.isEmpty ? 0 : 20);
      }),
      // buildTextField(labelText: 'Command Description', textController: Controller.newDeviceCont),
      // const SizedBox(height: 20),
      Obx(() {
        return Column(
          children: [
            buildTextField(
              title: 'Pouring',
              commandText: CommandController.commandCtrl.text,
              errorText: CommandController.commandErrorText.value,
              commandTextController: CommandController.commandCtrl,
              onChanged: CommandController.validateCommmandInput,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showPouringDialog(context);
              },
              child: const Text('Next'),
            ),
          ],
        );
      }),

      Obx(() {
        return SizedBox(height: CommandController.commandErrorText.isEmpty ? 0 : 20);
      }),
      //const SizedBox(height: 10),

      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: MyCustomButton(
                customWidget: const Text('Cancel'),
                isCircleButton: false, buttonWidth: 100,
                onPressedAction: () {
                  CommandController.isEditCommand.value = false;
                  Navigator.pop(context);
                }
            ),
          ),
          const SizedBox(width: 20,),
          Flexible(
            child: MyCustomButton(
                customWidget: const Text('Save'),
                isCircleButton: false, buttonWidth: 100,
                onPressedAction: () {

                  CommandController.validateCommmandInput();

                  if (CommandController.isInputCommandValid.isTrue) {
                    CommandController.saveNewCommand();
                    DeviceController.refreshNewCommandButtonState();

                    if (CommandController.isEditCommand.isTrue) {
                      CommandController.isEditCommand.value = false;
                    }
                    Navigator.pop(context);
                  }
                }
            ),
          ),
        ],
      )
    ];

    return actionList;
  }
}

void showPouringDialog(BuildContext context) {
  showCustomDialog(
    context: context,
    actionList: [const CommandView()],
    title: 'Pouring'
  );
}
*/