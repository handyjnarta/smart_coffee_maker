import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import 'package:flutter_bluetooth/app/helper/command_menu.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:flutter_bluetooth/app/models/recipes.dart';
import 'package:flutter_bluetooth/app/views/add_recipe_view.dart';
import 'package:flutter_bluetooth/main.dart';
import 'package:get/get.dart';
import '../../utils.dart';
import '/services/firestore_service.dart';

class RecipeController extends GetxController {
  static var isInsertNewRecipe = false;
  static var isEditRecipe = false;
  static bool isSaveRecipeBtnClicked = false;
  static var enableNewCommandBtn = false.obs;
  static var enableSaveRecipeBtn = false.obs;
  static RxList<Recipes> recipeList = <Recipes>[].obs;
  static Recipes? currentRecipe;
  static int recipeIndex = -1;
  static int recipeCount = 0;
  static Map<String, dynamic> oldRecipeData = {};

  static TextEditingController recipeNameController = TextEditingController();
  static TextEditingController turnOnTextController = TextEditingController();
  static TextEditingController turnOffTextController = TextEditingController();
  static TextEditingController recipeSetpointController =
      TextEditingController();

  static String selectedTitle = '';
  static RxString errorText = ''.obs;

  static FirestoreService firestoreService = FirestoreService();

  static void refreshNewCommandButtonState() {
    enableNewCommandBtn.value = false;

    if (recipeNameController.text.length < 3) {
      errorText.value = 'Recipe name minimal 3 characters';
    } else {
      errorText.value = '';
      int newDevIndex = recipeList.indexWhere(
          (element) => element.recipeName == recipeNameController.text);

      if ((isInsertNewRecipe && newDevIndex > -1) ||
          (isEditRecipe &&
              newDevIndex > -1 &&
              recipeNameController.text !=
                  oldRecipeData['oldRecipe']['recipeName'])) {
        errorText.value = 'Recipe name already used';
      } else {
        if (currentRecipe != null) {
          if (currentRecipe!.commandList.length < maxCommandCount) {
            enableNewCommandBtn.value = true;
          }
        } else {
          enableNewCommandBtn.value = true;
        }
      }
    }
  }

  static void loadRecipeListFromStorage({bool isLoadFromInitApp = true}) async {
    if (isLoadFromInitApp) {
      recipeList.clear();
      recipeList
          .addAll(await RecipesManager.instance.loadRecipesListFromFirestore());
      ctrl.refreshLogs(
          text: 'Recipes loaded from Firestore on app start',
          sourceId: SourceId.statusId);
    } else {
      showConfirmDialog(
          context: Get.context!,
          title: 'Reload recipes confirm',
          text: 'Reload all recipes from Firestore?'
              '\nRecipe count in Firestore: ${RecipesManager.instance.getRecipesCount}',
          onOkPressed: () async {
            Navigator.pop(Get.context!);
            recipeList.clear();
            recipeList.addAll(
                await RecipesManager.instance.loadRecipesListFromFirestore());
            ctrl.refreshLogs(
                text: 'Recipes loaded from Firestore',
                sourceId: SourceId.statusId);
            showGetxSnackbar('Recipe loaded', 'Recipe loaded from Firestore');
          });
    }
  }

  static void saveRecipeListIntoStorage() {
    showConfirmDialog(
        context: Get.context!,
        title: 'Save recipes confirm',
        text: 'Save all recipes into Firestore?',
        onOkPressed: () async {
          Navigator.pop(Get.context!);
          await RecipesManager.instance
              .saveRecipesListIntoFirestore(recipeList);
          ctrl.refreshLogs(
              text: 'Recipes saved into Firestore',
              sourceId: SourceId.statusId);
          showGetxSnackbar('Recipe saved', 'Recipes saved into Firestore OK');
          debugPrint('Recipe list has been successfully stored into Firebase.');
        });
  }

  static void createNewRecipe() {
    isInsertNewRecipe = true;
    isEditRecipe = false;
    enableSaveRecipeBtn.value = false;
    enableNewCommandBtn.value = false;
    currentRecipe = null;
    isSaveRecipeBtnClicked = false;
    recipeCount = recipeList.length;
    recipeNameController.clear();
    recipeSetpointController.clear();
    CommandController.commandMenuList.clear();
  }

  static void editRecipe() {
    isSaveRecipeBtnClicked = false;
    isInsertNewRecipe = false;
    isEditRecipe = true;
    errorText.value = '';

    currentRecipe = recipeList[recipeIndex];
    oldRecipeData['oldRecipe'] = {
      'recipeName': currentRecipe!.recipeName,
      'commandList': [...currentRecipe!.commandList],
    };

    recipeNameController.text = currentRecipe!.recipeName;

    if (currentRecipe!.commandList.length < maxCommandCount) {
      enableNewCommandBtn.value = true;
    } else {
      enableNewCommandBtn.value = false;
    }

    CommandController.commandMenuList.clear();

    int index = 0;
    for (final cmd in currentRecipe!.commandList) {
      CommandController.commandTextEditCtrlList[index].text = cmd.command;
      CommandController.commandMenuList.add(CommandMenu(
        titleText: cmd.title,
        commandText: cmd.command,
        readOnly: true,
        commandController: CommandController.commandTextEditCtrlList[index],
        onDeleteButtonPressed: RecipeController.deleteSelectedCommand,
        onEditButtonPressed: RecipeController.editSelectedCommand,
      ));
      index++;
    }
  }

  static void refreshSaveRecipeButtonState() {
    if (currentRecipe != null) {
      if (currentRecipe!.commandList.length < minCommandCount ||
          errorText.isNotEmpty) {
        enableSaveRecipeBtn.value = false;

        if (errorText.isNotEmpty && enableNewCommandBtn.isFalse) {
          enableSaveRecipeBtn.value = true;
        }
      } else {
        enableSaveRecipeBtn.value = true;
      }
    }
  }

  static void saveRecipeData() {
    isSaveRecipeBtnClicked = true;

    if (currentRecipe?.recipeName != recipeNameController.text) {
      ctrl.refreshLogs(
          text:
              'Recipe "${currentRecipe?.recipeName}" changed to "${recipeNameController.text}"');
      currentRecipe?.setNewRecipe = recipeNameController.text;
    }

    if (isEditRecipe) {
      recipeList[recipeIndex] = currentRecipe!;
      showGetxSnackbar('Edit success',
          'Recipe "${currentRecipe?.recipeName}" edited successfully');
      ctrl.refreshLogs(
          text: 'Recipe "${currentRecipe?.recipeName}" edited successfully');
    } else {
      recipeList.add(currentRecipe!);
      showGetxSnackbar(
          'Save recipe OK', 'Recipe: "${currentRecipe?.recipeName}" saved');
      ctrl.refreshLogs(text: 'Recipe "${currentRecipe?.recipeName}" saved');
    }
    for (final data in recipeList) {
      debugPrint('[recipe_controller] recipe name: ${data.recipeName}');
    }
  }

  static void onNewCommandButtonPressed() {
    CommandController.commandCtrl.clear();
    CommandController.commandTitleCtrl.clear();
    CommandController.commandLogText.clear();
  }

  static VoidCallback? editSelectedCommand() {
    debugPrint('');
    debugPrint('[recipe_controller] selected title to edit: $selectedTitle');
    CommandController.commandIndexToEdit = currentRecipe!.commandList
        .indexWhere((element) => element.title == selectedTitle);
    CommandController.oldCommand = currentRecipe!
        .commandList[CommandController.commandIndexToEdit].command;
    CommandController.isEditCommand.value = true;
    CommandController.commandTitleCtrl.text =
        currentRecipe!.commandList[CommandController.commandIndexToEdit].title;
    CommandController.commandCtrl.text = currentRecipe!
        .commandList[CommandController.commandIndexToEdit].command;
    CommandController.commandLogText.text = currentRecipe!
        .commandList[CommandController.commandIndexToEdit].logText;
    AddRecipeView.editCommand(Get.context!);
    return null;
  }

  static VoidCallback? deleteSelectedCommand() {
    debugPrint(
        '[recipe_controller] selected title to delete: $selectedTitle from recipe ${currentRecipe!.recipeName}');
    int commandIndexToDelete = -1;
    commandIndexToDelete = currentRecipe!.commandList
        .indexWhere((element) => element.title == selectedTitle);

    if (currentRecipe!.commandList.isNotEmpty) {
      currentRecipe?.commandList.removeAt(commandIndexToDelete);
      CommandController.commandMenuList.removeAt(commandIndexToDelete);
    }

    refreshNewCommandButtonState();

    return null;
  }
}
