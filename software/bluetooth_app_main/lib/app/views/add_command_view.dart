import 'package:flutter/material.dart';
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
                  // if (CommandController.isEditCommand.isTrue) {
                  //   CommandController.isEditCommand.value = false;
                  // }

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
        return StatefulPouringDialog();
      },
    );
  }
}

class StatefulPouringDialog extends StatefulWidget {
  @override
  _StatefulPouringDialogState createState() => _StatefulPouringDialogState();
}

class _StatefulPouringDialogState extends State<StatefulPouringDialog> {
  late String title;

  @override
  void initState() {
    super.initState();
    _updateTitle();
  }

  void _updateTitle() {
    if (CommandController.isEditCommand.isTrue) {
      title = 'Pouring Step ${RecipeController.selectedNumSteps}';
    } else {
      title =
          'Pouring Step ${(RecipeController.currentRecipe!.commandList.length) + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextField(
            title: 'Total Water',
            commandText: '1-600',
            errorText: CommandController.commandvolumeErrorText(),
            commandTextController: CommandController.commandvolumeCtrl,
          ),
          buildTextField(
            title: 'Pouring Time',
            commandText: '1-30',
            errorText: CommandController.commandTimePouringErrorText(),
            commandTextController: CommandController.commandTimePouring,
          ),
          buildTextField(
            title: 'Delay Time',
            commandText: '1-30',
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
              PouringDialogController.onNextPressed(context);
              setState(() {
                _updateTitle();
              });
            }
          },
          child: Obx(() =>
              Text(CommandController.isEditCommand.isTrue ? 'Save' : 'Next')),
        ),
      ],
    );
  }
}
