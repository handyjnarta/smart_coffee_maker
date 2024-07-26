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
  static var commandTitleErrorText = ''.obs;
  static var commandErrorText = ''.obs;
  static String oldCommand = '';
  static var stepsCount = 0.obs; // Jumlah langkah pouring
  static var currentStep = 0.obs; // Langkah pouring saat ini
  static var commandTitleCtrl = TextEditingController();
  //static var commandTitleErrorText = ''.obs;
  static var commandCtrl = TextEditingController();
  //static var commandErrorText = ''.obs;
  //static var isEditCommand = false.obs;
  //static var isInputCommandValid = false.obs;

  //static TextEditingController commandCtrl = TextEditingController();
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

  static void saveNewCommand(String text) {
    //validateCommandInput();
    if (!isInputCommandValid.value) return;

    //commandTextEditCtrlList[commandId].text = commandCtrl.text;

    var newCommand = Commands(
      numStep: commandnumStepCtrl.text,
      volume: commandvolumeCtrl.text,
      timePouring: commandTimePouring.text,
      timeInterval: commandTimeInterval.text,
    );

    if (RecipeController().currentRecipe.value == null) {
      RecipeController().currentRecipe = Recipes(
        id: RecipeController().selectedTitle.value,
        setpoint: RecipeController().recipeSetpointController.text,
        recipeName: RecipeController().recipeNameController.text,
        status: false,
        commandList: [newCommand],
      ) as Rxn<Recipes>;
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

    RecipeController().refreshSaveRecipeButtonState();
  }

  static void validateCommandInput(String text) {
    isInputCommandValid.value = false;
    commandTitleErrorText.value = '';
    commandErrorText.value = '';

    if (int.parse(commandnumStepCtrl.text) < 0) {
      debugPrint('[command_controller] input title command not valid');
      commandTitleErrorText.value = 'Numstep minimal 1 kak';
      return;
    }
    if (int.parse(commandvolumeCtrl.text) < 0) {
      debugPrint('[command_controller] input command not valid');
      commandErrorText.value = 'Please input the right volume';
      return;
    }
    if (int.parse(commandTimeInterval.text) < 0) {
      debugPrint('[command_controller] input command not valid');
      commandErrorText.value = 'Please input the right Time Interval';
      return;
    }
    if (int.parse(commandTimePouring.text) < 0) {
      debugPrint('[command_controller] input command not valid');
      commandErrorText.value = 'Please input the right Time Pouring';
      return;
    }

    isInputCommandValid.value = true;
  }

}
