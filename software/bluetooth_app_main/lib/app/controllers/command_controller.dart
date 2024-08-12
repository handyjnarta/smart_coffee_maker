import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/utils.dart';
import 'package:get/get.dart';
import '../helper/command_menu.dart';
import '../models/commands.dart';
import '../models/recipes.dart';
import 'recipe_controller.dart';

class CommandController extends GetxController {
  final RecipeController recipeController = Get.find<RecipeController>();

  static var commandMenuList = <CommandMenu>[].obs;
  static var isEditCommand = false.obs;
  static var isInsertNewRecipe = false.obs;
  static var isInputCommandValid = false.obs;
  static var commandIndexToEdit = 0;
  static var commandnumStepErrorText = ''.obs;
  static var commandvolumeErrorText = ''.obs;
  static var commandTimePouringErrorText = ''.obs;
  static var commandTimeIntervalErrorText = ''.obs;
  static var commandErrorText = ''.obs;
  static String oldCommand = '';
  static var currentStep = 0.obs;

  static var commandTitleCtrl = TextEditingController();
  static var commandCtrl = TextEditingController();
  static var commandnumStepCtrl = TextEditingController();
  static var commandvolumeCtrl = TextEditingController();
  static var commandTimePouring = TextEditingController();
  static var commandTimeInterval = TextEditingController();
  static var commandSetpointCtrl = TextEditingController();
  static var commandSetpointError = TextEditingController();
  static int numstepA = 0;

  @override
  void onInit() {
    super.onInit();
  }

  static void resetSteps() {
    currentStep.value = 1;
  }

  static List<TextEditingController> commandTextEditCtrlList =
      List<TextEditingController>.generate(
          maxCommandCount, (index) => TextEditingController(),
          growable: false);

  static void saveNewCommand() {
    RecipeController recipeController = Get.find<RecipeController>();

    if (!isInputCommandValid.value) return;

    if (isEditCommand.isTrue) {
      commandIndexToEdit = int.parse(RecipeController.selectedNumSteps) - 1;
      debugPrint('Editing command at step: ${commandIndexToEdit + 1}');
    } else {
      currentStep.value = commandMenuList.length + 1;
    }

    var newCommand = Commands(
      numStep: isEditCommand.isTrue
          ? (commandIndexToEdit + 1).toString()
          : currentStep.value.toString(),
      volume: commandvolumeCtrl.text,
      timePouring: commandTimePouring.text,
      timeInterval: commandTimeInterval.text,
    );

    if (RecipeController.currentRecipe == null) {
      RecipeController.currentRecipe = Recipes(
        id: recipeController.recipeCount.value,
        setpoint: RecipeController.recipeSetpointController.text,
        recipeName: RecipeController.recipeNameController.text,
        commandList: [newCommand],
      );
    } else {
      if (isEditCommand.isTrue) {
        RecipeController.currentRecipe!.commandList[commandIndexToEdit] =
            newCommand;
      } else {
        RecipeController.currentRecipe!.commandList.add(newCommand);
      }
    }

    if (isEditCommand.isFalse) {
      commandMenuList.add(CommandMenu(
        numStep: currentStep.value.toString(),
        volume: commandvolumeCtrl.text,
        timePouring: commandTimePouring.text,
        timeInterval: commandTimeInterval.text,
        readOnly: true,
        onDeleteButtonPressed: () {
          recipeController.deleteSelectedCommand();
        },
        onEditButtonPressed: () {
          debugPrint('Editing command at step: ${commandIndexToEdit + 1}');
          recipeController.editSelectedCommand();
        },
      ));
    } else {
      commandMenuList[commandIndexToEdit] = CommandMenu(
        numStep: (commandIndexToEdit + 1).toString(),
        volume: commandvolumeCtrl.text,
        timePouring: commandTimePouring.text,
        timeInterval: commandTimeInterval.text,
        readOnly: true,
        onDeleteButtonPressed: recipeController.deleteSelectedCommand,
        onEditButtonPressed: () {
          debugPrint('Editing command at step: ${commandIndexToEdit + 1}');
          recipeController.editSelectedCommand();
        },
      );
      debugPrint('Command menu list:');
      debugPrint('numStep: ${commandMenuList[commandIndexToEdit].numStep}');
      debugPrint('volume: ${commandMenuList[commandIndexToEdit].volume}');
      debugPrint(
          'timePouring: ${commandMenuList[commandIndexToEdit].timePouring}');
      debugPrint(
          'timeInterval: ${commandMenuList[commandIndexToEdit].timeInterval}');
    }

    debugPrint(
        'Current recipe command list: ${RecipeController.currentRecipe!.commandList.map((command) => command.toJson()).toList()}');
  }

  static void validateCommandInput() {
    // Reset validation state
    isInputCommandValid.value = false;
    commandvolumeErrorText.value = '';
    commandTimePouringErrorText.value = '';
    commandTimeIntervalErrorText.value = '';

    // Validation checks
    if (commandvolumeCtrl.text.isEmpty ||
        int.parse(commandvolumeCtrl.text) < 1 ||
        int.parse(commandvolumeCtrl.text) > 200) {
      showGetxSnackbar('Error', 'Value of total water must between 1-200 ml');
      return;
    }
    if (commandTimeInterval.text.isEmpty ||
        int.parse(commandTimeInterval.text) < 1 ||
        int.parse(commandTimeInterval.text) > 60) {
      showGetxSnackbar('Error', 'Value of time delay must between 1-60 second');
      return;
    }
    if (commandTimePouring.text.isEmpty ||
        int.parse(commandTimePouring.text) < 1 ||
        int.parse(commandTimePouring.text) > 60) {
      showGetxSnackbar(
          'Error', 'Value of time pouring must between 1-60 second');
      return;
    }
    isInputCommandValid.value = true;
  }

  static void validateNewCommandInput() {
    isInputCommandValid.value = false;
    commandnumStepErrorText.value = '';

    if (commandnumStepCtrl.text.isEmpty ||
        int.parse(commandnumStepCtrl.text) < 1 ||
        int.parse(commandnumStepCtrl.text) > 10) {
      showGetxSnackbar('Error', 'Value of numStep must between 1-10');
      return;
    }
    if (RecipeController.recipeSetpointController.text.isEmpty ||
        int.parse(RecipeController.recipeSetpointController.text) < 30 ||
        int.parse(RecipeController.recipeSetpointController.text) > 90) {
      showGetxSnackbar(
          'Error', 'Value of setpoint must between 30-90 degree celcius');
      return;
    }
    isInputCommandValid.value = true;
  }
}
