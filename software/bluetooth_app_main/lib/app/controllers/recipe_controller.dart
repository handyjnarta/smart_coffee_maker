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

  /*
  final recipeNameController = TextEditingController();
  final turnOnTextController = TextEditingController();
  final turnOffTextController = TextEditingController();
  final recipeSetpointController = TextEditingController(); */

  String selectedNumSteps = '';
  var errorText = ''.obs;

  final FirestoreService firestoreService = FirestoreService();

  void refreshNewCommandButtonState() {
    enableNewCommandBtn.value = false;

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
        if (currentRecipe != null) {
          if (currentRecipe!.commandList.length < maxCommandCount) {
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
    //debugPrint('hey syang index : ${recipeIndex.value}');
    int index = -1;
    String targetName = namaresep;
    for (int i = 0; i < RecipeController.recipeList.length; i++) {
      if (RecipeController.recipeList[i].recipeName == targetName) {
        index = i;
        break;
      }
    }
    recipeIndex.value = index;
    isSaveRecipeBtnClicked.value = false;
    isInsertNewRecipe.value = false;
    isEditRecipe.value = true;
    errorText.value = '';
    //CommandController.commandIndexToEdit = currentRecipe!.commandList.indexWhere((element) => element.numStep == RecipeController.currentRecipe!.commandList[int.parse(numStep) - 1].numStep);
    currentRecipe = recipeList[recipeIndex.value];
    oldRecipeData['oldRecipe'] = {
      'recipeName': currentRecipe!.recipeName,
      'recipeSetpoint': currentRecipe!.setpoint,
      'commandList': [...currentRecipe!.commandList],
    };

    recipeNameController.text = currentRecipe!.recipeName;
    recipeSetpointController.text = currentRecipe!.setpoint.toString();

    if (currentRecipe!.commandList.length < maxCommandCount) {
      enableNewCommandBtn.value = true;
    } else {
      enableNewCommandBtn.value = false;
    }

    CommandController.commandMenuList.clear();

    // ignore: unused_local_variable
    for (final cmd in currentRecipe!.commandList) {
      CommandController
          .commandTextEditCtrlList[CommandController.currentStep.value]
          .text = cmd.numStep;
      CommandController.commandMenuList.add(CommandMenu(
        numStep: CommandController.currentStep.value.toString(),
        volume: CommandController.commandvolumeCtrl.text,
        timeInterval: CommandController.commandTimeInterval.text,
        timePouring: CommandController.commandTimePouring.text,
        readOnly: true,
        onDeleteButtonPressed: () => deleteSelectedCommand(),
        onEditButtonPressed: () => editSelectedCommand,
      ));
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

    if (isEditRecipe.value) {
      recipeList[recipeIndex.value] = currentRecipe!;
      showGetxSnackbar('Edit success',
          'Recipe "${currentRecipe!.recipeName}" edited successfully');
      refreshLogs('Recipe "${currentRecipe!.recipeName}" edited successfully');
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
    CommandController.commandvolumeCtrl.text = '';
    CommandController.commandTimePouring.text = '';
    CommandController.commandTimeInterval.text = '';
  }

  VoidCallback? editSelectedCommand() {
    CommandController.isEditCommand.value = true;
    CommandView.showPouringDialog(Get.context!);
    CommandController.commandIndexToEdit = RecipeController
        .currentRecipe!.commandList
        .indexWhere((element) => (element.numStep) == selectedNumSteps);
    debugPrint('Commandindextoedit: ${CommandController.commandIndexToEdit}');

    if (CommandController.commandIndexToEdit != -1) {
      var commandToEdit =
          currentRecipe!.commandList[CommandController.commandIndexToEdit];

      // Debug print command details
      debugPrint('Command to Edit:');
      debugPrint('Num Step: ${commandToEdit.numStep}');
      debugPrint('Volume: ${commandToEdit.volume}');
      debugPrint('Time Pouring: ${commandToEdit.timePouring}');
      debugPrint('Time Interval: ${commandToEdit.timeInterval}');
      commandToEdit.numStep = selectedNumSteps;
      // Debug print command details after updating
      debugPrint('Num Step after update: ${commandToEdit.numStep}');

      // Update the numStep to match selectedNumSteps
      // Update the text controllers with the command data
      CommandController.commandvolumeCtrl.text = commandToEdit.volume;
      CommandController.commandTimePouring.text = commandToEdit.timePouring;
      CommandController.commandTimeInterval.text = commandToEdit.timeInterval;
    } else {
      debugPrint(
          'Command with numStep ${CommandController.commandIndexToEdit} not found');
    }

    return null;
  }

  VoidCallback? deleteSelectedCommand() {
    debugPrint(
        '[recipe_controller] selected title to delete: $selectedNumSteps from recipe ${currentRecipe!.recipeName}');
    int commandIndexToDelete = currentRecipe!.id;

    if (currentRecipe!.commandList.isNotEmpty) {
      currentRecipe?.commandList.removeAt(commandIndexToDelete);
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
