import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import 'package:flutter_bluetooth/app/helper/command_menu.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:flutter_bluetooth/app/models/recipes.dart';
import 'package:flutter_bluetooth/app/views/add_command_view.dart';
import 'package:flutter_bluetooth/main.dart';
import 'package:get/get.dart';
import '../../utils.dart';
import '/services/firestore_service.dart';

class RecipeController extends GetxController {
  // Observable variables
  var isInsertNewRecipe = false.obs;
  var isEditRecipe = false.obs;
  var isSaveRecipeBtnClicked = false.obs;
  var enableNewCommandBtn = false.obs;
  var enableSaveRecipeBtn = false.obs;
  var recipeList = <Recipes>[].obs;
  var currentRecipe = Rxn<Recipes>();
  var recipeIndex = 0.obs;
  static Recipes? currentRecipeX;
  var recipeCount = 0.obs;
  var oldRecipeData = {}.obs;

  static TextEditingController recipeNameController = TextEditingController();
  static TextEditingController turnOffTextController = TextEditingController();
  static TextEditingController turnOnTextController = TextEditingController();
  static TextEditingController recipeSetpointController =
      TextEditingController();

  /*
  final recipeNameController = TextEditingController();
  final turnOnTextController = TextEditingController();
  final turnOffTextController = TextEditingController();
  final recipeSetpointController = TextEditingController(); */

  String selectedTitle = '';
  var errorText = ''.obs;

  final FirestoreService firestoreService = FirestoreService();

  void refreshNewCommandButtonState() {
    enableNewCommandBtn.value = false;

    // Attempt to parse the recipe name as an integer
    //final recipeName = int.parse(recipeNameController.text); untuk apa

    // Debug print the value of recipeName
    //debugPrint('Parsed recipeName as integer: $recipeName'); untuk affah

    // Check if the recipe name length is less than 3 characters
    if (recipeNameController.text.isEmpty) {
      errorText.value = 'Recipe name required';
    } else {
      // Clear the error message if input is valid
      errorText.value = '';

      // Debug print the current recipe name
      debugPrint('Recipe name entered: ${recipeNameController.text}');

      // Check if the recipe name already exists
      int newDevIndex = recipeList.indexWhere(
          (element) => element.recipeName == recipeNameController.text);

      debugPrint('Index of existing recipe with the same name: $newDevIndex');

      if ((isInsertNewRecipe.value && newDevIndex > -1) ||
          (isEditRecipe.value &&
              newDevIndex > -1 &&
              recipeNameController.text !=
                  oldRecipeData['oldRecipe']['recipeName'])) {
        errorText.value = 'Recipe name already used';
      } else {
        if (currentRecipe.value != null) {
          if (currentRecipe.value!.commandList.length < maxCommandCount) {
            enableNewCommandBtn.value = true;
            debugPrint('New command button enabled');
          }
        } else {
          enableNewCommandBtn.value = true;
          debugPrint('New command button enabled in different way');
        }
      }
    }
  }

  Future<void> loadRecipeListFromStorage(
      {bool isLoadFromInitApp = true}) async {
    if (isLoadFromInitApp) {
      recipeList.clear();
      recipeList
          .addAll(await RecipesManager.instance.loadRecipesListFromFirestore());
      refreshLogs('Recipes loaded from Firestore on app start');
    } else {
      showConfirmDialog(
        context: Get.context!,
        title: 'Reload recipes confirm',
        text:
            'Reload all recipes from Firestore?\nRecipe count in Firestore: ${RecipesManager.instance.getRecipesCount}',
        onOkPressed: () async {
          Navigator.pop(Get.context!);
          recipeList.clear();
          recipeList.addAll(
              await RecipesManager.instance.loadRecipesListFromFirestore());
          refreshLogs('Recipes loaded from Firestore');
          showGetxSnackbar('Recipe loaded', 'Recipe loaded from Firestore');
        },
      );
    }
  }

  Future<void> saveRecipeListIntoStorage() async {
    showConfirmDialog(
      context: Get.context!,
      title: 'Save recipes confirm',
      text: 'Save all recipes into Firestore?',
      onOkPressed: () async {
        Navigator.pop(Get.context!);
        await RecipesManager.instance.saveRecipesListIntoFirestore(recipeList);
        refreshLogs('Recipes saved into Firestore');
        showGetxSnackbar('Recipe saved', 'Recipes saved into Firestore OK');
      },
    );
  }

  void createNewRecipe() {
    isInsertNewRecipe.value = true;
    isEditRecipe.value = false;
    enableSaveRecipeBtn.value = false;
    enableNewCommandBtn.value = false;
    currentRecipe.value = Recipes(
      recipeName: '',
      id: recipeCount.value,
      status: false,
      setpoint: '',
      commandList: [],
    );
    isSaveRecipeBtnClicked.value = false;
    recipeCount.value = recipeList.length;
    recipeNameController.clear();
    recipeSetpointController.clear();
    CommandController.commandMenuList.clear();
  }

  void editRecipe() {
    isSaveRecipeBtnClicked.value = false;
    isInsertNewRecipe.value = false;
    isEditRecipe.value = true;
    errorText.value = '';

    currentRecipe.value = recipeList[recipeIndex.value];
    oldRecipeData['oldRecipe'] = {
      'recipeName': currentRecipe.value!.recipeName,
      'recipeSetpoint': currentRecipe.value!.setpoint,
      'commandList': [...currentRecipe.value!.commandList],
    };

    recipeNameController.text = currentRecipe.value!.recipeName;
    recipeSetpointController.text = currentRecipe.value!.setpoint.toString();

    if (currentRecipe.value!.commandList.length < maxCommandCount) {
      enableNewCommandBtn.value = true;
    } else {
      enableNewCommandBtn.value = false;
    }

    CommandController.commandMenuList.clear();

    // ignore: unused_local_variable
    for (final cmd in currentRecipe.value!.commandList) {
      CommandController.commandMenuList.add(CommandMenu(
        numStep: CommandController.currentStep.value.toString(),
        volume: CommandController.commandvolumeCtrl.text,
        timeInterval: CommandController.commandTimeInterval.text,
        timePouring: CommandController.commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: () => deleteSelectedCommand(),
        onEditButtonPressed: () => editSelectedCommand(),
      ));
    }
  }

  void refreshSaveRecipeButtonState() {
    if (currentRecipe.value != null) {
      if (currentRecipe.value!.commandList.length < minCommandCount ||
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

  void saveRecipeData() {
    isSaveRecipeBtnClicked.value = true;
/*
    if (currentRecipe.value?.recipeName != recipeNameController.text) {
      refreshLogs(
          'Recipe "${currentRecipe.value?.recipeName}" changed to "${recipeNameController.text}"');
      currentRecipe.value?.setNewRecipe = recipeNameController.text;
    }

    if (int.parse(currentRecipe.value!.setpoint) !=
        int.parse(recipeSetpointController.text)) {
      refreshLogs(
          'Setpoint "${currentRecipe.value?.setpoint}" changed to "${recipeSetpointController.text}"');
      currentRecipe.value?.setpoint = recipeSetpointController.text;
    }
*/
    if (isEditRecipe.value) {
      recipeList[recipeIndex.value] = currentRecipe.value!;
      showGetxSnackbar('Edit success',
          'Recipe "${currentRecipe.value?.recipeName}" edited successfully');
      refreshLogs(
          'Recipe "${currentRecipe.value?.recipeName}" edited successfully');
    } else {
      currentRecipeX = currentRecipe.value!;
      recipeList.add(currentRecipeX!);
      showGetxSnackbar(
          'ada berapa ya', 'Recipe: "ada ${recipeList.length}" saved');
      refreshLogs('Recipe "${currentRecipe.value?.recipeName}" saved');
    }
    for (final data in recipeList) {
      debugPrint('[recipe_controller] recipe name: ${data.recipeName}');
    }
  }

  void onNewCommandButtonPressed() {
    CommandController.commandvolumeCtrl.text = '';
    CommandController.commandTimePouring.text = '';
    CommandController.commandTimeInterval.text = '';
  }

  VoidCallback? editSelectedCommand() {
    debugPrint('[recipe_controller] selected title to edit: $selectedTitle');
    CommandController.isEditCommand.value = true;
    CommandView.showPouringDialog(Get.context!);

    // Find the command to edit based on the current step value
    var commandToEdit = currentRecipe.value!.commandList.firstWhere(
        (cmd) => cmd.numStep == CommandController.currentStep.value.toString());

    debugPrint('commandtoEdit : $commandToEdit');

    CommandController.commandIndexToEdit =
        currentRecipe.value!.commandList.indexOf(commandToEdit);

    // Update the text controllers with the command data
    CommandController.commandvolumeCtrl.text = commandToEdit.volume;
    CommandController.commandTimePouring.text = commandToEdit.timePouring;
    CommandController.commandTimeInterval.text = commandToEdit.timeInterval;

    return null;
  }

  VoidCallback? deleteSelectedCommand() {
    debugPrint(
        '[recipe_controller] selected title to delete: $selectedTitle from recipe ${currentRecipe.value!.recipeName}');
    int commandIndexToDelete = currentRecipe.value!.id;

    if (currentRecipe.value!.commandList.isNotEmpty) {
      currentRecipe.value?.commandList.removeAt(commandIndexToDelete);
      CommandController.commandMenuList.removeAt(commandIndexToDelete);
    }

    refreshNewCommandButtonState();
    refreshSaveRecipeButtonState();

    return null;
  }

  void refreshLogs(String text) {
    ctrl.refreshLogs(text: text, sourceId: SourceId.statusId);
  }
}
