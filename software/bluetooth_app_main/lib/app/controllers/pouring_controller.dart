import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'command_controller.dart';
import 'recipe_controller.dart';
import '../views/add_command_view.dart';

class PouringDialogController extends GetxController {
  static void onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  static void onNextPressed(BuildContext context) {
    debugPrint('Current step: ${CommandController.currentStep.value}');
    debugPrint(
        'Command num step: ${CommandController.commandnumStepCtrl.text}');

    CommandController.validateCommandInput();

    if (CommandController.isInputCommandValid.isFalse) {
      return;
    }

    CommandController.saveNewCommand();

    if (CommandController.isEditCommand.isTrue) {
      RecipeController().onNewCommandButtonPressed();
      Navigator.pop(context);
      CommandController.isEditCommand.value = false;
    } else {
      if (CommandController.currentStep.value <
          int.parse(CommandController.commandnumStepCtrl.text)) {
        CommandController.addCommandIndexToEdit(
            CommandController.currentStep.value);
        CommandController.currentStep.value++;
        RecipeController().onNewCommandButtonPressed();
        CommandView.showPouringDialog(context);
        Navigator.pop(context);
      } else if (CommandController.currentStep.value ==
          int.parse(CommandController.commandnumStepCtrl.text)) {
        CommandController.addCommandIndexToEdit(
            CommandController.currentStep.value);
        RecipeController().onNewCommandButtonPressed();
        Navigator.pop(context);
        Navigator.pop(context);
        CommandController.resetSteps();
      } else {
        CommandController.resetSteps();
        Navigator.pop(context);
      }
    }
  }
}
