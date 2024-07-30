import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'command_controller.dart';
import 'recipe_controller.dart';
import '../views/add_command_view.dart';

class PouringDialogController {
  static void onCancelPressed(BuildContext context) {
    Navigator.pop(context);
    //CommandController.resetSteps();
  }

  static void onNextPressed(BuildContext context) {
    CommandController.validateCommandInput();
    if (CommandController.isInputCommandValid.isFalse) {
      return;
    }
    CommandController.saveNewCommand();
    if ((CommandController.currentStep.value) <
        int.parse(CommandController.commandnumStepCtrl.text)) {
      CommandController.currentStep.value =
          CommandController.currentStep.value + 1;
      RecipeController().onNewCommandButtonPressed();
      CommandView.showPouringDialog(
          context); // Show the dialog for the next step
      Navigator.pop(context);
    } else if ((CommandController.currentStep.value) ==
        int.parse(CommandController.commandnumStepCtrl.text)) {
      RecipeController().onNewCommandButtonPressed();
      Navigator.pop(context);
      Navigator.pop(context);
      CommandController.resetSteps();
    } else {
      CommandController.resetSteps();
      Navigator.pop(context);
    }
    debugPrint('Current step: ${CommandController.currentStep.value}');
    debugPrint(
        'Command num step: ${CommandController.commandnumStepCtrl.text}');
  }
}
