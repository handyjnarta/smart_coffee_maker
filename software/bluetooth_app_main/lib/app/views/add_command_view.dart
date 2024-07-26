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
          commandText: '30-90',
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
              commandText: '0-10',
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
                showGetxSnackbar(
                    'step: ${int.parse(CommandController.commandnumStepCtrl.text)}',
                    'current step: ${CommandController.currentStep.value}');
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
          return Text(
              'Pouring Step ${CommandController.currentStep.value + 1}');
        }),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextField(
              title: 'Total Water',
              commandText: '0-600',
              errorText: 'Please input the right volume',
              commandTextController: CommandController.commandvolumeCtrl,
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Pouring Time',
              commandText: '0-30',
              errorText:
                  'Please input the right Time Pouring', // Tangani error jika ada
              commandTextController: CommandController.commandTimePouring,
              //onChanged: (value) {},
            ),
            buildTextField(
              title: 'Delay Time',
              commandText: '0-30',
              errorText:
                  'Please input the right Time Interval', // Tangani error jika ada
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
              showGetxSnackbar(
                  'step: ${int.parse(CommandController.commandnumStepCtrl.text)}',
                  'current step: ${CommandController.currentStep.value}');
              if (CommandController.currentStep.value <
                  int.parse(CommandController.commandnumStepCtrl.text) - 1) {
                CommandController.currentStep.value =
                    CommandController.currentStep.value + 1;
                //showGetxSnackbar('step: ${CommandController.currentStep.value}', 'Device list refreshed');
                //debugPrint('step: ${CommandController.currentStep.value}');
                Navigator.pop(context);
                CommandController.saveNewCommand();
                CommandController.commandCtrl.text;
                showPouringDialog(
                    context); // Menampilkan dialog untuk langkah berikutnya
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
