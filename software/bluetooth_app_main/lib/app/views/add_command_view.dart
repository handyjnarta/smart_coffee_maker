import 'package:flutter/material.dart';
//import 'package:flutter_bluetooth/app/controllers/device_controller.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';

import 'package:get/get.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import '../custom_widget/custom_button.dart';
import '../helper/widget_helper.dart';
import '../controllers/pouring_controller.dart';

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
              customWidget: const Text('Next 1'),
              isCircleButton: false,
              buttonWidth: 60,
              onPressedAction: () {
                CommandController.validateNewCommandInput();
                if (CommandController.isInputCommandValid.isTrue) {
                  if (CommandController.isEditCommand.isTrue) {
                    CommandController.isEditCommand.value = false;
                  }

                  showPouringDialog(context);
                }
              },
            ),
          ),
        ],
      )
    ];
    return actionList;
  }

  static void showPouringDialog(BuildContext context) {
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
                commandText: '0-600',
                errorText: CommandController.commandvolumeErrorText(),
                commandTextController: CommandController.commandvolumeCtrl,
              ),
              buildTextField(
                title: 'Pouring Time',
                commandText: '0-30',
                errorText: CommandController.commandTimePouringErrorText(),
                commandTextController: CommandController.commandTimePouring,
              ),
              buildTextField(
                title: 'Delay Time',
                commandText: '0-30',
                errorText: CommandController.commandTimeIntervalErrorText(),
                commandTextController: CommandController.commandTimeInterval,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => PouringDialogController.onCancelPressed(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => PouringDialogController.onNextPressed(context),
              child: Obx(() => Text(
                  CommandController.isEditCommand.isTrue ? 'Save' : 'Next')),
            ),
          ],
        );
      },
    );
  }
}
