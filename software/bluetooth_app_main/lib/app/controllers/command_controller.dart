import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:get/get.dart';
import '../helper/command_menu.dart';
import '../models/commands.dart';
import '../models/recipes.dart';
import 'recipe_controller.dart';

class CommandController extends GetxController {
  final RecipeController recipeController = Get.find<RecipeController>();
  static List<CommandMenu> commandMenuList = <CommandMenu>[].obs;
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
  static var stepsCount = 0.obs; // Number of pouring steps
  static var currentStep = 0.obs; // Current pouring step
  static TextEditingController commandTitleCtrl = TextEditingController();
  static TextEditingController commandCtrl = TextEditingController();
  static TextEditingController commandnumStepCtrl = TextEditingController();
  static TextEditingController commandvolumeCtrl = TextEditingController();
  static TextEditingController commandTimePouring = TextEditingController();
  static TextEditingController commandTimeInterval = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Ensure controllers are initialized
    commandTitleCtrl = TextEditingController();
    commandCtrl = TextEditingController();
    commandnumStepCtrl = TextEditingController();
    commandvolumeCtrl = TextEditingController();
    commandTimePouring = TextEditingController();
    commandTimeInterval = TextEditingController();
  }

  static void resetSteps() {
    stepsCount.value = 0;
    currentStep.value = 0;
  }

  static List<TextEditingController> commandTextEditCtrlList =
      List<TextEditingController>.generate(
          maxCommandCount, (index) => TextEditingController(),
          growable: false);

  static void saveNewCommand() {
    // Validate command input before saving
    validateCommandInput();

    // If input is not valid, do not proceed with saving
    if (!isInputCommandValid.value) return;

    var newCommand = Commands(
      numStep: commandnumStepCtrl.text,
      volume: commandvolumeCtrl.text,
      timePouring: commandTimePouring.text,
      timeInterval: commandTimeInterval.text,
    );

    // Use the existing instance of RecipeController
    RecipeController recipeController = Get.find<RecipeController>();

    // Check if currentRecipe is null before trying to access its properties
    if (recipeController.currentRecipe.value == null) {
      debugPrint('Initializing currentRecipe because it is null');
      recipeController.currentRecipe.value = Recipes(
        id: recipeController.selectedTitle.value,
        setpoint: RecipeController
            .recipeSetpointController.text, // Accessing statically
        recipeName:
            RecipeController.recipeNameController.text, // Accessing statically
        status: false,
        commandList: [newCommand],
      );
    } else {
      debugPrint('currentRecipe is not null, proceeding to update it');
      if (isEditCommand.isTrue) {
        recipeController.currentRecipe.value!.commandList[commandIndexToEdit] =
            newCommand;
      } else {
        recipeController.currentRecipe.value!.commandList.add(newCommand);
      }
    }

    // Debug print the updated currentRecipe
    if (recipeController.currentRecipe.value != null) {
      debugPrint(
          'Updated currentRecipe: ${recipeController.currentRecipe.value!.toString()}');
      debugPrint(
          'Updated Command List: ${recipeController.currentRecipe.value!.commandList.map((command) => command.toString()).toList()}');
    } else {
      debugPrint('Error: currentRecipe is still null after initialization');
    }

    if (isEditCommand.isFalse) {
      commandMenuList.add(CommandMenu(
        numStep: commandnumStepCtrl.text,
        volume: commandvolumeCtrl.text,
        timeInterval: commandTimeInterval.text,
        timePouring: commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: recipeController.deleteSelectedCommand,
        onEditButtonPressed: recipeController.editSelectedCommand,
      ));
    } else {
      commandMenuList[commandIndexToEdit] = CommandMenu(
        numStep: commandnumStepCtrl.text,
        volume: commandvolumeCtrl.text,
        timeInterval: commandTimeInterval.text,
        timePouring: commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: recipeController.deleteSelectedCommand,
        onEditButtonPressed: recipeController.editSelectedCommand,
      );
    }

    // Print the command menu list to verify it is updated
    debugPrint('Command Menu List: $commandMenuList');

    recipeController.refreshSaveRecipeButtonState();
  }

  static void validateCommandInput() {
    isInputCommandValid.value = false;
    commandnumStepErrorText.value = '';
    commandvolumeErrorText.value = '';
    commandTimePouringErrorText.value = '';
    commandTimeIntervalErrorText.value = '';

    if (commandnumStepCtrl.text.isEmpty ||
        int.tryParse(commandnumStepCtrl.text) == null ||
        int.parse(commandnumStepCtrl.text) < 0) {
      debugPrint('[command_controller] input title command not valid');
      commandnumStepErrorText.value = 'Numstep minimal 1 kak';
      return;
    }
    if (commandvolumeCtrl.text.isEmpty ||
        int.tryParse(commandvolumeCtrl.text) == null ||
        int.parse(commandvolumeCtrl.text) < 0) {
      debugPrint('[command_controller] input command not valid');
      commandvolumeErrorText.value = 'Please input the right volume';
      return;
    }
    if (commandTimeInterval.text.isEmpty ||
        int.tryParse(commandTimeInterval.text) == null ||
        int.parse(commandTimeInterval.text) < 0) {
      debugPrint('[command_controller] input command not valid');
      commandTimeIntervalErrorText.value =
          'Please input the right Time Interval';
      return;
    }
    if (commandTimePouring.text.isEmpty ||
        int.tryParse(commandTimePouring.text) == null ||
        int.parse(commandTimePouring.text) < 0) {
      debugPrint('[command_controller] input command not valid');
      commandTimePouringErrorText.value = 'Please input the right Time Pouring';
      return;
    }

    isInputCommandValid.value = true;
  }
}
