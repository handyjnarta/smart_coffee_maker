import 'package:flutter/material.dart';
//import 'package:flutter_bluetooth/app/controllers/device_controller.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
//import 'package:flutter_bluetooth/app/views/add_pouring_view.dart';
import 'package:get/get.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import '../custom_widget/custom_button.dart';
import '../helper/widget_helper.dart';

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
          commandText: 'Add setpoint',
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
              commandText: 'Add Pouring Step',
              errorText: CommandController.commandErrorText.value,
              commandTextController: CommandController.commandCtrl,
              //onChanged: CommandController.validateCommandInput,
            ),
            const SizedBox(height: 10),
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
              buttonWidth: 60,
              onPressedAction: () {
                CommandController.isEditCommand.value = false;
                CommandController.resetSteps();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: MyCustomButton(
              customWidget: const Text('Save'),
              isCircleButton: false,
              buttonWidth: 60,
              onPressedAction: () {
                CommandController.validateCommandInput(
                    CommandController.commandCtrl.text);

                if (CommandController.isInputCommandValid.isTrue) {
                  CommandController.saveNewCommand(
                      CommandController.commandCtrl.text);
                  RecipeController().refreshNewCommandButtonState();

                  if (CommandController.isEditCommand.isTrue) {
                    CommandController.isEditCommand.value = false;
                  }
                  CommandController.resetSteps();
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Flexible(
            child: MyCustomButton(
              customWidget: const Text('Next'),
              isCircleButton: false,
              buttonWidth: 60,
              onPressedAction: () {
                showPouringDialog(context);
                CommandController.validateCommandInput(
                    CommandController.commandCtrl.text);

                if (CommandController.isInputCommandValid.isTrue) {
                  
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
          return Text('Pouring Step ${CommandController.currentStep.value + 1}');
        }),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextField(
              title: 'Total Water',
              commandText: 'Input total water', // Inisialisasi dengan nilai kosong atau yang ada
              errorText: 'Input invalid', // Tangani error jika ada
              commandTextController: TextEditingController(),
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Pouring Time',
              commandText: 'Input Pouring Time', // Inisialisasi dengan nilai kosong atau yang ada
              errorText: 'Input Invalid', // Tangani error jika ada
              commandTextController: TextEditingController(),
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Delay Time',
              commandText: 'Input Delay Time', // Inisialisasi dengan nilai kosong atau yang ada
              errorText: 'Input Invalid', // Tangani error jika ada
              commandTextController: TextEditingController(),
              //onChanged: (value) {},
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CommandController.saveNewCommand(
                  CommandController.commandCtrl.text);
              CommandController.resetSteps();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (CommandController.currentStep.value <
                  CommandController.stepsCount.value) {
                CommandController.currentStep.value++;
                debugPrint('step: $CommandController.currentStep.value');
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