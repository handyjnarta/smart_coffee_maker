import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
import '../custom_widget/custom_button.dart';

class CommandMenu extends StatelessWidget {
  String numStep;
  final String volume;
  final String timePouring;
  final String timeInterval;
  final bool readOnly;
  final VoidCallback? onDeleteButtonPressed;
  final VoidCallback? onEditButtonPressed;

  CommandMenu({
    Key? key,
    this.readOnly = false,
    this.onEditButtonPressed,
    this.onDeleteButtonPressed,
    required this.numStep,
    required this.volume,
    required this.timeInterval,
    required this.timePouring,
  }) : super(key: key);

@override
  Widget build(BuildContext context) {
    // Assuming numStep is a string you receive or fetch from somewhere
    RecipeController.updateSelectedNumSteps(numStep);

    int selectedNumSteps = int.parse(RecipeController.selectedNumSteps);
    int index = RecipeController.currentRecipe!.commandList.indexWhere(
        (element) => element.numStep == (selectedNumSteps).toString());
    String commandText;

    debugPrint('[widget] SelectedNumSteps: $selectedNumSteps');
    debugPrint('[widget] Index: $index');
    debugPrint(
        '[widget] CommandList: ${RecipeController.currentRecipe!.commandList.map((e) => e.numStep).toList()}');

    if (index >= 0 &&
        index < RecipeController.currentRecipe!.commandList.length) {
      commandText =
          'Command ke ${RecipeController.currentRecipe!.commandList[index].numStep}';
    } else {
      commandText = 'Invalid command';
    }
    return buildDeviceCommandMenu(
      commandText: commandText,
      numStep: numStep,
      volume: volume,
      timeInterval: timeInterval,
      timePouring: timePouring,
      isTextEditingReadOnly: readOnly,
      onEditButtonPressed: onEditButtonPressed,
      onDeleteButtonPressed: onDeleteButtonPressed,
    );
  }
  Widget buildDeviceCommandMenu({
    required String commandText,
    required String numStep,
    required String volume,
    required String timeInterval,
    required String timePouring,
    bool isTextEditingReadOnly = false,
    void Function()? onEditButtonPressed,
    void Function()? onDeleteButtonPressed,
  }) {
    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 220,
                    height: 100,
                    child: Text(
                      commandText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              MyCustomButton(
                commandNumStep: numStep,
                customWidget: const Icon(Icons.edit),
                onPressedAction: onEditButtonPressed,
              ),
              MyCustomButton(
                commandNumStep: numStep,
                customWidget: const Icon(Icons.delete),
                onPressedAction: onDeleteButtonPressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
