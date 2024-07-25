import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:get/get.dart';
import '../helper/command_menu.dart';
import '../models/commands.dart';
import '../models/recipes.dart';
import 'recipe_controller.dart';

class CommandController extends GetxController {
  static List<CommandMenu> commandMenuList = <CommandMenu>[].obs;
  static var isEditCommand = false.obs;
  static var isInputCommandValid = false.obs;
  static int commandIndexToEdit = -1;
  static var commandTitleErrorText = ''.obs;
  static var commandErrorText = ''.obs;
  static String oldCommand = '';

  static TextEditingController commandnumStepCtrl = TextEditingController();
  static TextEditingController commandvolumeCtrl = TextEditingController();
  static TextEditingController commandTimePouring = TextEditingController();
  static TextEditingController commandTimeInterval = TextEditingController();

  static List<TextEditingController> commandTextEditCtrlList =
      List<TextEditingController>.generate(
          maxCommandCount, (index) => TextEditingController(),
          growable: false);

  /*static void validateCommandInput() {
    isInputCommandValid.value = false;
    commandTitleErrorText.value = '';
    commandErrorText.value = '';

    if (commandnumStepCtrl.text.numericOnly() = false) { 
      debugPrint('[command_controller] input title command not valid');
      commandTitleErrorText.value = 'Title length min 3 characters';
      return;
    } else if (commandCtrl.text.isEmpty) {
      debugPrint('[command_controller] input command not valid');
      commandErrorText.value = 'Please input command';
      return;
    }

    isInputCommandValid.value = true;
  } */

  static void saveNewCommand() {
    //validateCommandInput();
    if (!isInputCommandValid.value) return;

    int commandId =
        isEditCommand.isTrue ? commandIndexToEdit : commandMenuList.length;

    //commandTextEditCtrlList[commandId].text = commandCtrl.text;

    var newCommand = Commands(
      numStep: commandnumStepCtrl.text,
      volume: commandvolumeCtrl.text,
      timePouring: commandTimePouring.text,
      timeInterval: commandTimeInterval.text,
    );

    if (RecipeController.currentRecipe == null) {
      RecipeController.currentRecipe = Recipes(
        id: RecipeController.selectedTitle,
        setpoint: RecipeController.recipeSetpointController.text,
        recipeName: RecipeController.recipeNameController.text,
        status: false,
        commandList: [newCommand],
      ) as Rxn<Recipes>;
    } else {
      if (isEditCommand.isTrue) {
        RecipeController.currentRecipe?.commandList[commandIndexToEdit] =
            newCommand;
      } else {
        RecipeController.currentRecipe?.commandList.add(newCommand);
      }
    }

    if (isEditCommand.isFalse) {
      commandMenuList.add(CommandMenu(
        numStep: commandnumStepCtrl.text,
        volume: commandvolumeCtrl.text,
        timeInterval: commandTimeInterval.text,
        timePouring: commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: RecipeController.deleteSelectedCommand,
        onEditButtonPressed: RecipeController.editSelectedCommand,
      ));
    } else {
      commandMenuList[commandIndexToEdit] = CommandMenu(
        numStep: commandnumStepCtrl.text,
        volume: commandvolumeCtrl.text,
        timeInterval: commandTimeInterval.text,
        timePouring: commandTimePouring.text,
        readOnly: true,
        commandController: commandTextEditCtrlList[commandId],
        onDeleteButtonPressed: RecipeController.deleteSelectedCommand,
        onEditButtonPressed: RecipeController.editSelectedCommand,
      );
    }

    RecipeController.refreshSaveRecipeButtonState();
  }
}
