import 'package:flutter/material.dart';
//import 'package:flutter_bluetooth/app/controllers/device_controller.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
//import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:flutter_bluetooth/utils.dart';
//import 'package:flutter_bluetooth/app/views/add_pouring_view.dart';
import 'package:get/get.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import '../custom_widget/custom_button.dart';
import '../helper/widget_helper.dart';
//import 'dart:js_util';

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
          commandText: RecipeController.recipeSetpointController.text,
          errorText: CommandController.commandErrorText.value,
          commandTextController: RecipeController.recipeSetpointController,
          //onChanged: CommandController.validateCommandInput,
        );
      }),
      Obx(() {
        return Column(
          children: [
            buildTextField(
              title: 'Pouring Steps',
              commandText: CommandController.commandnumStepCtrl.text,
              errorText: CommandController.commandErrorText.value,
              commandTextController: CommandController.commandnumStepCtrl,
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
                CommandController.validateCommandInput();

                if (CommandController.isInputCommandValid.isTrue) {
                  CommandController.saveNewCommand();
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
          const SizedBox(width: 10),
          Flexible(
            child: MyCustomButton(
              customWidget: const Text('Next'),
              isCircleButton: false,
              buttonWidth: 60,
              onPressedAction: () {
                showGetxSnackbar('step: ${int.parse(CommandController.commandnumStepCtrl.text)}', 'current step: ${CommandController.currentStep.value}');
                showPouringDialog(context);
                CommandController.validateCommandInput();

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
              commandText: CommandController.commandvolumeCtrl.text, // Inisialisasi dengan nilai kosong atau yang ada
              errorText: 'Please input the right volume',
              commandTextController: CommandController.commandvolumeCtrl,
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Pouring Time',
              commandText: CommandController.commandTimePouring.text, // Inisialisasi dengan nilai kosong atau yang ada
              errorText: 'Please input the right Time Pouring', // Tangani error jika ada
              commandTextController: CommandController.commandTimePouring,
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Delay Time',
              commandText: CommandController.commandTimeInterval.text, // Inisialisasi dengan nilai kosong atau yang ada
              errorText: 'Please input the right Time Interval', // Tangani error jika ada
              commandTextController: CommandController.commandTimeInterval,
              //onChanged: (value) {},
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CommandController.saveNewCommand();
              CommandController.resetSteps();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              //debugPrint('step: ${CommandController.currentStep.value}');
              showGetxSnackbar('step: ${int.parse(CommandController.commandnumStepCtrl.text)}', 'current step: ${CommandController.currentStep.value}');
              if (CommandController.currentStep.value <
                  int.parse(CommandController.commandnumStepCtrl.text) - 1) {
                CommandController.currentStep.value = CommandController.currentStep.value + 1;
                //showGetxSnackbar('step: ${CommandController.currentStep.value}', 'Device list refreshed');
                //debugPrint('step: ${CommandController.currentStep.value}');
                Navigator.pop(context);
                CommandController.saveNewCommand();
                CommandController.commandCtrl.text;
                showPouringDialog(context); // Menampilkan dialog untuk langkah berikutnya
              } else if (CommandController.currentStep.value ==
                  int.parse(CommandController.commandnumStepCtrl.text) - 1) {
                CommandController.currentStep.value++;
                CommandController.saveNewCommand();
                //debugPrint('step: ${CommandController.currentStep.value}');
                CommandController.resetSteps();
                Navigator.pop(context);
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