import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';

import 'package:get/get.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import '../custom_widget/custom_button.dart';
import '../helper/widget_helper.dart';
import '../controllers/pouring_controller.dart';

class CommandView extends StatelessWidget {
  static bool isFirstCommandAdded = true;
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
          title: 'Setpoint (°C)',
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
              commandText: '1-10',
              errorText: CommandController.commandErrorText.value,
              commandTextController: CommandController.commandnumStepCtrl,
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
                //CommandController.resetSteps();
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
                  //CommandController.resetSteps();
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
    debugPrint(
        'Current step value before showing dialog: ${CommandController.currentStep.value}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Obx(() {
            if (CommandController.isEditCommand.isTrue) {
              return Text('Pouring Step ${RecipeController.selectedNumSteps}');
            } else if (RecipeController.currentRecipe != null &&
                RecipeController.currentRecipe!.commandList.length > 1) {
              return Text(
                  'Pouring Step ${(RecipeController.currentRecipe!.commandList.length) + 1}');
            } else {
              return Text(
                  'Pouring Step ${(CommandController.currentStep.value) + 1}');
            }
          }),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTextField(
                title: 'Total Water (ml)',
                commandText: '1-200',
                errorText: CommandController.commandvolumeErrorText(),
                commandTextController: CommandController.commandvolumeCtrl,
              ),
              buildTextField(
                title: 'Pouring Time (s)',
                commandText: '1-60',
                errorText: CommandController.commandTimePouringErrorText(),
                commandTextController: CommandController.commandTimePouring,
              ),
              buildTextField(
                title: 'Delay Time (s)',
                commandText: '1-60',
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
              onPressed: () {
                debugPrint(
                    'Command current step command view: ${CommandController.currentStep.value}');

                if (CommandController.isEditCommand.isTrue) {
                  CommandController.saveNewCommand();
                  Navigator.pop(context);
                  CommandController.isEditCommand.value = false;
                } else {
                  // Add the command first
                  PouringDialogController.onNextPressed(context);

                  // Check if this is the first time a command is added
                  if (!isFirstCommandAdded) {
                    // If not the first command, close the dialog after saving
                    Navigator.pop(context);
                    debugPrint('[addcommand] not first anymore');
                  }
                }
              },
              child: Obx(() {
                // Change the button text dynamically based on conditions
                if (CommandController.isEditCommand.isTrue) {
                  return const Text('Save');
                } else if (RecipeController.currentRecipe != null &&
                    RecipeController.currentRecipe!.commandList.isNotEmpty) {
                  return const Text('Save');
                } else {
                  return const Text('Next');
                }
              }),
            ),
          ],
        );
      },
    );
  }
}
