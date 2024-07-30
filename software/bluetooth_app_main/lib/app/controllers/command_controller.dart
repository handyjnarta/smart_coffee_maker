import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:get/get.dart';
import '../helper/command_menu.dart';
import '../models/commands.dart';
import '../models/recipes.dart';
import 'recipe_controller.dart';

class CommandController extends GetxController {
  final RecipeController recipeController = Get.find<RecipeController>();

  // Observable lists and variables
  static var commandMenuList = <CommandMenu>[].obs;
  static var isEditCommand = false.obs;
  static var isInsertNewRecipe = false.obs;
  static var isInputCommandValid = false.obs;
  static int commandIndexToEdit = -1;
  static var commandnumStepErrorText = ''.obs;
  static var commandvolumeErrorText = ''.obs;
  static var commandTimePouringErrorText = ''.obs;
  static var commandTimeIntervalErrorText = ''.obs;
  static var commandErrorText = ''.obs;
  static String oldCommand = '';
  static var stepsCount = 0.obs;
  static var currentStep = 0.obs;

  // TextEditingControllers
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
    // Initialize controllers if necessary
  }

  static void resetSteps() {
    stepsCount.value = 0;
    currentStep.value = 0;
  }

  // List of TextEditingControllers
  static List<TextEditingController> commandTextEditCtrlList =
      List<TextEditingController>.generate(
          maxCommandCount, (index) => TextEditingController(),
          growable: false);

  static void saveNewCommand() {
    validateCommandInput();

    if (!isInputCommandValid.value) return;

    var newCommand = Commands(
      numStep: currentStep.value.toString(),
      volume: commandvolumeCtrl.text,
      timePouring: commandTimeInterval.text,
      timeInterval: commandTimePouring.text,
    );

    RecipeController recipeController = Get.find<RecipeController>();

    if (recipeController.currentRecipe.value == null) {
      recipeController.currentRecipe.value = Recipes(
        id: recipeController.selectedTitle.value,
        setpoint: RecipeController.recipeSetpointController.text,
        recipeName: RecipeController.recipeNameController.text,
        status: false,
        commandList: [newCommand],
      );
    } else {
      if (isEditCommand.isTrue) {
        recipeController.currentRecipe.value!.commandList[commandIndexToEdit] =
            newCommand;
      } else {
        recipeController.currentRecipe.value!.commandList.add(newCommand);
      }
    }

    // Update the command menu list based on the command state
    if (isEditCommand.isFalse) {
      commandMenuList.add(CommandMenu(
        numStep: currentStep.value.toString(),
        volume: commandvolumeCtrl.text,
        timePouring: commandTimeInterval.text,
        timeInterval: commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: recipeController.deleteSelectedCommand,
        onEditButtonPressed: recipeController.editSelectedCommand,
      ));
    } else {
      commandMenuList[commandIndexToEdit] = CommandMenu(
        numStep: currentStep.value.toString(),
        volume: commandvolumeCtrl.text,
        timePouring: commandTimeInterval.text,
        timeInterval: commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: recipeController.deleteSelectedCommand,
        onEditButtonPressed: recipeController.editSelectedCommand,
      );
    }
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
}
