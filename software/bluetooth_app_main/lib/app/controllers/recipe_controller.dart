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
  static RxList<Recipes> recipeList = <Recipes>[].obs;
  //var currentRecipe = Rxn<Recipes>();
  var recipeIndex = 0.obs;
  static Recipes? currentRecipe;
  var recipeCount = 0.obs;
  var oldRecipeData = {}.obs;

  static TextEditingController recipeNameController = TextEditingController();
  static TextEditingController turnOffTextController = TextEditingController();
  static TextEditingController turnOnTextController = TextEditingController();
  static TextEditingController recipeSetpointController =
      TextEditingController();

  static String selectedNumSteps = '';
  var errorText = ''.obs;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void onInit() {
    super.onInit();
    ever(isEditRecipe, (value) {
      debugPrint('[recipe controller] isEditRecipe updated: $value');
    });
  }

  void refreshNewCommandButtonState() {
    enableNewCommandBtn.value = false;

    // Check if the recipe name length is less than 3 characters
    if (recipeNameController.text.isEmpty) {
      errorText.value = 'Recipe name required';
    } else {
      // Clear the error message if input is valid
      errorText.value = '';

      // Debug print the current recipe name
      debugPrint(
          ' recipe controller] Recipe name entered: ${recipeNameController.text}');

      // Check if the recipe name already exists
      int newDevIndex = recipeList.indexWhere(
          (element) => element.recipeName == recipeNameController.text);

      debugPrint(
          '[recipe controller] Index of existing recipe with the same name: $newDevIndex');

      if ((isInsertNewRecipe.value && newDevIndex > -1) ||
          (isEditRecipe.value &&
              newDevIndex > -1 &&
              recipeNameController.text !=
                  oldRecipeData['oldRecipe']['recipeName'])) {
        errorText.value = 'Recipe name already used';
      } else {
        if (currentRecipe != null) {
          if (currentRecipe!.commandList.length < maxCommandCount) {
            enableNewCommandBtn.value = true;
            debugPrint(' [recipe controller] New command button enabled');
          }
        } else {
          enableNewCommandBtn.value = true;
          debugPrint(
              '[recipe controller] New command button enabled in different way');
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
    currentRecipe = Recipes(
      recipeName: '',
      id: recipeCount.value,
      //status: false,
      setpoint: '',
      commandList: [],
    );
    isSaveRecipeBtnClicked.value = false;
    recipeCount.value = recipeList.length;
    recipeNameController.clear();
    recipeSetpointController.clear();
    CommandController.commandMenuList.clear();
  }

  void editRecipe(String namaresep) {
    isSaveRecipeBtnClicked.value = false;
    isInsertNewRecipe.value = false;
    isEditRecipe.value = true;
    debugPrint('edit true ga: ${isEditRecipe.value}');
    errorText.value = '';
    int index = -1;
    String targetName = namaresep;

    // Find the index of the recipe with the given name
    for (int i = 0; i < RecipeController.recipeList.length; i++) {
      if (RecipeController.recipeList[i].recipeName == targetName) {
        index = i;
        break;
      }
    }

    // Check if the recipe was found
    if (index == -1) {
      debugPrint('[recipe controller] Recipe not found: $namaresep');
      errorText.value = 'Recipe not found';
      return;
    }

    recipeIndex.value = index;
    debugPrint('[recipe controller] index : ${recipeIndex.value}');
    debugPrint('[recipe_con]nama resep di recipe View: $namaresep');

    // Set the current recipe and backup the old data
    currentRecipe = RecipeController.recipeList[recipeIndex.value];
    oldRecipeData['oldRecipe'] = {
      'recipeName': currentRecipe!.recipeName,
      'recipeSetpoint': currentRecipe!.setpoint,
      'commandList': [...currentRecipe!.commandList],
    };

    recipeNameController.text = currentRecipe!.recipeName;
    recipeSetpointController.text = currentRecipe!.setpoint.toString();

    // Enable or disable the new command button
    enableNewCommandBtn.value =
        currentRecipe!.commandList.length < maxCommandCount;

    // Clear and populate the command menu list
    CommandController.commandMenuList.clear();
    for (final cmd in currentRecipe!.commandList) {
      CommandController
          .commandTextEditCtrlList[CommandController.currentStep.value]
          .text = cmd.numStep.toString();
      CommandController.commandMenuList.add(CommandMenu(
        numStep: cmd.numStep.toString(),
        volume: cmd.volume.toString(),
        timeInterval: cmd.timeInterval.toString(),
        timePouring: cmd.timePouring.toString(),
        readOnly: true,
        onDeleteButtonPressed: () => deleteSelectedCommand(),
        onEditButtonPressed: () => editSelectedCommand(),
      ));

      // Increment the current step after adding each command
      CommandController.currentStep.value++;
    }
  }

  void refreshSaveRecipeButtonState() {
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

  void saveRecipeData() {
    isSaveRecipeBtnClicked.value = true;
    debugPrint('edit true ga- save nih: ${isEditRecipe.value}');

    if (currentRecipe?.recipeName != recipeNameController.text) {
      refreshLogs(
          'Recipe "${currentRecipe?.recipeName}" changed to "${recipeNameController.text}"');
      currentRecipe?.setNewRecipe = recipeNameController.text;
    }

    if (currentRecipe?.setpoint != recipeSetpointController.text) {
      refreshLogs(
          'Setpoint "${currentRecipe?.setpoint}" changed to "${recipeSetpointController.text}"');
      currentRecipe?.setNewRecipeSetpoint = recipeSetpointController.text;
    }

    int newDevIndex =
        recipeList.indexWhere((element) => element.id == currentRecipe!.id);

    if (isInsertNewRecipe.value && newDevIndex > -1) {
      errorText.value = 'Recipe ID already used';
      // Mengubah ID hanya jika ID sudah digunakan dan ini adalah resep baru
      int currID = currentRecipe!.id;
      currentRecipe!.setNewRecipeId = (currID + 1);
    }
    
    if (isEditRecipe.isTrue) {
      showGetxSnackbar('FUngsi ini sudah pindah tempat', 'ada yang salah');

    } else {
      recipeList.add(currentRecipe!); //buat void untuk menambahkan
      showGetxSnackbar(
          'Recipe saved', 'Recipe count: "${recipeList.length}" saved');
      refreshLogs('Recipe "${currentRecipe!.recipeName}" saved');
    }

    for (final data in recipeList) {
      debugPrint('[recipe_controller] recipe name: ${data.recipeName}');
      //debugPrint('[recipe_controller] bool: ${data.status}');
      debugPrint('[recipe_controller] id: ${data.id}');
      debugPrint('[recipe_controller] Setpoint: ${data.setpoint}');
    }
  }

  void onNewCommandButtonPressed() {
    //CommandController.resetSteps();
    //CommandController.commandnumStepCtrl.clear();
    CommandController.commandvolumeCtrl.text = '';
    CommandController.commandTimePouring.text = '';
    CommandController.commandTimeInterval.text = '';
  }

  void saveEditedRecipeData() {
    isSaveRecipeBtnClicked.value = true;
          recipeList[recipeIndex.value] = currentRecipe!;
          debugPrint('nama resep: ${recipeNameController.text} ');
          currentRecipe!.recipeName = recipeNameController.text;
          debugPrint('nama resep: ${currentRecipe?.recipeName} ');
      showGetxSnackbar('Edit success',
          'Recipe "${currentRecipe!.recipeName}" edited successfully');
      refreshLogs('Recipe "${currentRecipe!.recipeName}" edited successfully');
      isEditRecipe.value = false;
  }

  VoidCallback? editSelectedCommand() {
    debugPrint(
        '[recipe_con]nama resep di recipe View dr edit: ${currentRecipe?.recipeName}');
    CommandController.isEditCommand.value = true;
    CommandView.showPouringDialog(Get.context!);
    CommandController.commandIndexToEdit = RecipeController
        .currentRecipe!.commandList
        .indexWhere((element) => (element.numStep) == selectedNumSteps);
    debugPrint(
        '[recipe controller] Commandindextoedit: ${CommandController.commandIndexToEdit}');

    if (CommandController.commandIndexToEdit != -1) {
      var commandToEdit =
          currentRecipe!.commandList[CommandController.commandIndexToEdit];
      commandToEdit.numStep = selectedNumSteps;
      // selectedNumSteps = commandToEdit.numStep;
      CommandController.commandvolumeCtrl.text = commandToEdit.volume;
      CommandController.commandTimePouring.text = commandToEdit.timePouring;
      CommandController.commandTimeInterval.text = commandToEdit.timeInterval;

      debugPrint(
          '[recipe controller] Currentrecipe command list: ${currentRecipe!.commandList.map((command) => command.toJson()).toList()}');
      // Debug print the new command details
    } else {
      debugPrint(
          '[recipe controller] Command with numStep ${CommandController.commandIndexToEdit} not found');
    }

    return null;
  }

  VoidCallback? deleteSelectedCommand() {
    debugPrint(
        '[recipe_con]nama resep di recipe delete: ${currentRecipe?.recipeName}');
    debugPrint(
        '[recipe_con]selected numstep: ${RecipeController.selectedNumSteps}');

    // Convert selectedNumSteps to int for comparison
    int selectedStep = int.parse(selectedNumSteps);

    // Find the index of the command to delete
    int commandIndexToDelete = RecipeController.currentRecipe!.commandList
        .indexWhere((element) => int.parse(element.numStep) == selectedStep);
    debugPrint('[recipe_con] commandIndexToDelete: $commandIndexToDelete');

    int validRangeStart = 0;
    int validRangeEnd = RecipeController.currentRecipe!.commandList.length - 1;
    debugPrint(
        '[recipe controller] Valid index range: $validRangeStart to $validRangeEnd');

    if (commandIndexToDelete > -1 &&
        commandIndexToDelete >= validRangeStart &&
        commandIndexToDelete <= validRangeEnd) {
      // Remove from both lists
      CommandController.commandMenuList.removeAt(commandIndexToDelete);
      RecipeController.currentRecipe!.commandList
          .removeAt(commandIndexToDelete);

      // Update the numStep of commands that come after the deleted one
      for (int i = commandIndexToDelete;
          i < RecipeController.currentRecipe!.commandList.length;
          i++) {
        RecipeController.currentRecipe!.commandList[i].numStep =
            (i + 1).toString();
        CommandController.commandMenuList[i].numStep = (i + 1).toString();
      }

      // Notify listeners or update state if necessary
      // For example, if using a state management solution, call setState() or notifyListeners()

      // Log the updated lists after deletion
      debugPrint(
          '[recipe controller] Deleted command at index: $commandIndexToDelete');
      debugPrint(
          '[recipe controller] Updated command menu list: ${CommandController.commandMenuList.map((e) => e.numStep).toList()}');
      debugPrint(
          '[recipe controller] Updated command list: ${RecipeController.currentRecipe!.commandList.map((e) => e.numStep).toList()}');
      debugPrint(
          '[recipe controller] woi: ${currentRecipe!.commandList.map((command) => command.toJson()).toList()}');
    } else {
      // Log an error if the command is not found or list is empty
      debugPrint('Error: Command not found or index is out of valid range');
    }
    refreshNewCommandButtonState();
    refreshSaveRecipeButtonState();
    return null;
  }

  VoidCallback? editSelectedCommandfromEdit() {
    debugPrint(
        '[recipe_con]nama resep di recipe View dr edit: ${currentRecipe?.recipeName}');
    CommandController.isEditCommand.value = true;
    CommandView.showPouringDialog(Get.context!);
    CommandController.commandIndexToEdit = RecipeController
        .currentRecipe!.commandList
        .indexWhere((element) => (element.numStep) == selectedNumSteps);
    debugPrint('Commandindextoedit: ${CommandController.commandIndexToEdit}');

    if (CommandController.commandIndexToEdit != -1) {
      var commandToEdit =
          currentRecipe!.commandList[CommandController.commandIndexToEdit];
      commandToEdit.numStep = selectedNumSteps;
      // selectedNumSteps = commandToEdit.numStep;
      CommandController.commandvolumeCtrl.text = commandToEdit.volume;
      CommandController.commandTimePouring.text = commandToEdit.timePouring;
      CommandController.commandTimeInterval.text = commandToEdit.timeInterval;

      debugPrint(
          'Currentrecipe command list: ${currentRecipe!.commandList.map((command) => command.toJson()).toList()}');
      // Debug print the new command details
    } else {
      debugPrint(
          'Command with numStep ${CommandController.commandIndexToEdit} not found');
    }

    return null;
  }

  VoidCallback? deleteSelectedCommandfromEdit() {
    // Set the current recipe and backup the old data
    //currentRecipe = RecipeController.recipeList[recipeIndex.value];
    debugPrint(
        '[recipe_con]nama resep di recipe delete: ${currentRecipe?.recipeName}');
    // debugPrint(
    //     'Current command list: ${RecipeController.currentRecipe!.commandList.map((e) => e.numStep).toList()}');
    // debugPrint(
    //     'Current command menu list: ${CommandController.commandMenuList.map((e) => e.numStep).toList()}');
    debugPrint(
        'Current recipe command list: ${RecipeController.currentRecipe!.commandList.map((command) => command.toJson()).toList()}');
    //
    debugPrint(
        '[recipe_con]selected numstep: ${RecipeController.selectedNumSteps}');
    // Convert selectedNumSteps to int for comparison
    int selectedStep = int.parse(selectedNumSteps);
    //debugPrint('[recipe_con]selected step: $selectedStep');

    // Find the index of the command to delete
    int commandIndexToDelete = RecipeController.currentRecipe!.commandList
        .indexWhere((element) => int.parse(element.numStep) == selectedStep);
    debugPrint('[recipe_con] commandIndexToDelete: $commandIndexToDelete');

    int validRangeStart = 0;
    int validRangeEnd = RecipeController.currentRecipe!.commandList.length - 1;

    debugPrint('Valid index range: $validRangeStart to $validRangeEnd');

    if (commandIndexToDelete > -1 &&
        commandIndexToDelete >= validRangeStart &&
        commandIndexToDelete <= validRangeEnd) {
      // Remove from commandMenuList
      CommandController.commandMenuList.removeAt(commandIndexToDelete);
      RecipeController.currentRecipe!.commandList
          .removeAt(commandIndexToDelete);

      // Log the updated lists after deletion
      debugPrint('Deleted command at index: $commandIndexToDelete');
      debugPrint(
          'Updated command menu list: ${CommandController.commandMenuList.map((e) => e.numStep).toList()}');
      debugPrint(
          'Updated command list: ${RecipeController.currentRecipe!.commandList.map((e) => e.numStep).toList()}');
    } else {
      // Log an error if the command is not found or list is empty
      debugPrint('Error: Command not found or index is out of valid range');
    }
    refreshNewCommandButtonState();
    refreshSaveRecipeButtonState();
    return null;
  }

  void refreshLogs(String text) {
    ctrl.refreshLogs(text: text, sourceId: SourceId.statusId);
  }

  static void updateSelectedNumSteps(String newNumSteps) {
    selectedNumSteps = newNumSteps;
    debugPrint(
        '[recipe controller] Updated selectedNumSteps: $selectedNumSteps');
  }
}
