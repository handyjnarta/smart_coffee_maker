import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
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
    validateCommandInput();

    if (!isInputCommandValid.value) return;

    if (isEditCommand.isTrue) {
      //commandIndexToEdit = currentStep.value;
      debugPrint('Editing command at  glia step: ${commandIndexToEdit}');
    } else {
      currentStep.value = commandMenuList.length + 1;
    }

    var newCommand = Commands(
      numStep: currentStep.value.toString(),
      volume: commandvolumeCtrl.text,
      timePouring: commandTimePouring.text,
      timeInterval: commandTimeInterval.text,
    );

    RecipeController recipeController = Get.find<RecipeController>();

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
    // Find the command index by numStep

    // Update the command menu list based on the command state
    if (isEditCommand.isFalse) {
      commandMenuList.add(CommandMenu(
        numStep: currentStep.value.toString(),
        volume: commandvolumeCtrl.text,
        timePouring: commandTimePouring.text,
        timeInterval: commandTimeInterval.text,
        readOnly: true,
        onDeleteButtonPressed: recipeController.deleteSelectedCommand,
        onEditButtonPressed: () {
          debugPrint('ADD: ${commandIndexToEdit}');
          recipeController.editSelectedCommand();
        },
      ));
    } else {
      commandMenuList[commandIndexToEdit] = CommandMenu(
        numStep: currentStep.value.toString(),
        volume: commandvolumeCtrl.text,
        timePouring: commandTimePouring.text,
        timeInterval: commandTimeInterval.text,
        readOnly: true,
        onDeleteButtonPressed: recipeController.deleteSelectedCommand,
        onEditButtonPressed: () {
          //debugPrint('Editing command at current step: ${commandIndexToEdit}');
          recipeController.editSelectedCommand;
        },
      );
    }

    debugPrint(
        'Currentrecipe command list: ${RecipeController.currentRecipe!.commandList.map((command) => command.toJson()).toList()}');
    // Debug print the new command details
    debugPrint('New Command:');
    debugPrint('numStep: ${newCommand.numStep}');
    debugPrint('volume: ${newCommand.volume}');
    debugPrint('timePouring: ${newCommand.timePouring}');
    debugPrint('timeInterval: ${newCommand.timeInterval}');
  }

  static void validateCommandInput() {
    // Reset validation state
    isInputCommandValid.value = false;
    commandvolumeErrorText.value = '';
    commandTimePouringErrorText.value = '';
    commandTimeIntervalErrorText.value = '';

    // Validation checks
    if (commandvolumeCtrl.text.isEmpty ||
        int.parse(commandvolumeCtrl.text) <= 0) {
      commandvolumeErrorText.value = 'Please input the right volume';
      return;
    }
    if (commandTimeInterval.text.isEmpty ||
        int.parse(commandTimeInterval.text) <= 0) {
      commandTimeIntervalErrorText.value =
          'Please input the right Time Interval';
      return;
    }
    if (commandTimePouring.text.isEmpty ||
        int.parse(commandTimePouring.text) <= 0) {
      commandTimePouringErrorText.value = 'Please input the right Time Pouring';
      return;
    }
    isInputCommandValid.value = true;
  }

  static void validateNewCommandInput() {
    isInputCommandValid.value = false;
    commandnumStepErrorText.value = '';

    if (commandnumStepCtrl.text.isEmpty ||
        int.parse(commandnumStepCtrl.text) <= 0) {
      commandnumStepErrorText.value = 'Numstep minimal 1 kak';
      return;
    }
    if (RecipeController.recipeSetpointController.text.isEmpty ||
        int.parse(RecipeController.recipeSetpointController.text) <= 0) {
      commandvolumeErrorText.value = 'Please input the right volume';
      return;
    }
    isInputCommandValid.value = true;
  }

  //Method to add an index to the list
}
