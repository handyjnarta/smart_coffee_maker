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
  static var commandTitleCtrl = TextEditingController();
  static var commandCtrl = TextEditingController();
  static TextEditingController commandnumStepCtrl = TextEditingController();
  static TextEditingController commandvolumeCtrl = TextEditingController();
  static TextEditingController commandTimePouring = TextEditingController();
  static TextEditingController commandTimeInterval = TextEditingController();

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

    debugPrint('New Command: $newCommand');

    if (RecipeController().currentRecipe.value == null) {
      RecipeController().currentRecipe = Rxn<Recipes>(
        Recipes(
          id: RecipeController().selectedTitle.value,
          setpoint: RecipeController.recipeSetpointController.text,
          recipeName: RecipeController.recipeNameController.text,
          status: false,
          commandList: [newCommand],
        ),
      );
    } else {
      if (isEditCommand.isTrue) {
        RecipeController()
            .currentRecipe
            .value!
            .commandList[commandIndexToEdit] = newCommand;
      } else {
        RecipeController().currentRecipe.value!.commandList.add(newCommand);
      }
    }

    // Print the updated command list
    debugPrint(
        'Updated Command List: ${RecipeController().currentRecipe.value!.commandList.map((command) => command.toString()).toList()}');

    if (isEditCommand.isFalse) {
      commandMenuList.add(CommandMenu(
        numStep: commandnumStepCtrl.text,
        volume: commandvolumeCtrl.text,
        timeInterval: commandTimeInterval.text,
        timePouring: commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: RecipeController().deleteSelectedCommand,
        onEditButtonPressed: RecipeController().editSelectedCommand,
      ));
    } else {
      commandMenuList[commandIndexToEdit] = CommandMenu(
        numStep: commandnumStepCtrl.text,
        volume: commandvolumeCtrl.text,
        timeInterval: commandTimeInterval.text,
        timePouring: commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: RecipeController().deleteSelectedCommand,
        onEditButtonPressed: RecipeController().editSelectedCommand,
      );
    }

    // Print the command menu list to verify it is updated
    debugPrint('Command Menu List: $commandMenuList');

    RecipeController().refreshSaveRecipeButtonState();
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
