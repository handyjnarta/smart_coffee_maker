import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
//import 'package:flutter_bluetooth/app/controllers/global_controller.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

import '../../bluetooth_data.dart';
import '../../main.dart';
import '../../utils.dart';
import '../constant/constant.dart';
import 'add_recipe_view.dart';

enum PopupItems { edit, delete, run, editSP }

// ignore: must_be_immutable
class RecipesView extends StatelessWidget {
  const RecipesView({Key? key}) : super(key: key);
  //int index = 1;

  void runrecipe() {
    Navigator.pop(Get.context!);
    if (BluetoothData.isConnectedvalue == false) {
      showGetxSnackbar(
          'Cant run the recipe', 'Please connect the device first');
      return;
    }
    final RecipeController recipeController = Get.find<RecipeController>();
    int index = recipeController.recipeIndex.value;
    String recipeName = RecipeController.recipeList[index].recipeName;
    showGetxSnackbar('Recipe run', 'Recipe "$recipeName" ran now');
    int setpointval = int.parse(RecipeController.recipeList[index].setpoint);
    int numstepsval = RecipeController.recipeList[index].commandList.length;
    int volumeval = 0;
    int timeIntervalval = 0;
    int timePouringval = 0;
    ctrl.changeTab(1);
    String message = 'r';
    BluetoothData().sendMessageToBluetooth(message, true);
    debugPrint('message: $message');
    message = setpointval.toString();
    BluetoothData().sendMessageToBluetooth(message, true);
    debugPrint('message: $message');
    message = numstepsval.toString();
    BluetoothData().sendMessageToBluetooth(message, true);
    for (int i = 0; i < numstepsval; i++) {
      volumeval = int.parse(RecipeController.recipeList[index].commandList[i]
          .volume); // masukin untuk volume val di index numstepval nya
      message = volumeval.toString();
      BluetoothData().sendMessageToBluetooth(message, true);
      debugPrint('message: $message'); //volume
      timePouringval = int.parse(RecipeController
          .recipeList[index]
          .commandList[i]
          .timePouring); // masukin untuk timePouring val di index numstepval nya
      message = timePouringval.toString();
      BluetoothData().sendMessageToBluetooth(message, true);
      debugPrint('message: $message');
      timeIntervalval = int.parse(RecipeController
          .recipeList[index]
          .commandList[i]
          .timeInterval); // masukin untuk timeInterval val di index numstepval nya
      message = timeIntervalval.toString();
      BluetoothData().sendMessageToBluetooth(message, true);
      debugPrint('message: $message');
    }
  }

  void deleteRecipe() {
    final RecipeController recipeController = Get.find<RecipeController>();
    int index = recipeController.recipeIndex.value;
    Navigator.pop(Get.context!);
    String recipeName = RecipeController.recipeList[index].recipeName;
    RecipeController.recipeList.removeAt(index);
    ctrl.refreshLogs(text: 'Recipe "$recipeName" deleted');
    showGetxSnackbar('Recipe deleted', 'Recipe "$recipeName" deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return (RecipeController.recipeList.isNotEmpty)
          ? ListView.builder(
              itemCount: RecipeController.recipeList.length,
              itemBuilder: (BuildContext context, index) {
                debugPrint('[recipe_view] rebuilding listview');
                return buildRecipeContainer(
                    context: context,
                    recipeName: RecipeController.recipeList[index].recipeName,
                    //status: RecipeController.recipeList[index].status,
                    recipeIndex: index);
              })
          : const Center(
              child: Text(
              'No recipe found',
              style: TextStyle(fontSize: 22),
            ));
    });
  }

  void editSelectedRecipe(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();
    recipeController.isEditRecipe.value = true;
    int index = recipeController.recipeIndex.value;
    RecipeController()
        .editRecipe(RecipeController.recipeList[index].recipeName);
    debugPrint(
        '[recipe view]nama resep di recipe View: ${RecipeController.recipeList[index].recipeName}');

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return const AddRecipeView(title: 'Edit recipe');
        }).whenComplete(() {
      debugPrint('');
      debugPrint('[recipe_view] show modal bottom sheet closed (edit recipe)');
      debugPrint(
          '[recipe_view] RecipeController.isSaveRecipeBtnClicked: ${RecipeController().isSaveRecipeBtnClicked}');
    });
  }

  void createNewRecipe(BuildContext context) {
    RecipeController().createNewRecipe();
    //AddRecipeView.editCommand(context);

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return const AddRecipeView(title: 'Add new recipe');
        }).whenComplete(() {
      debugPrint(
          '[recipe_view] show modal bottom sheet closed (insert new recipe)');
    });
  }

  void editSetpoint(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();
    int index = recipeController.recipeIndex.value;

    TextEditingController setpointController = TextEditingController(
      text: RecipeController.recipeList[index].setpoint,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Setpoint'),
          content: TextField(
            controller: setpointController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Setpoint (°C)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                RecipeController.recipeList[index].setpoint =
                    setpointController.text;
                Navigator.of(context).pop();
                showGetxSnackbar('Setpoint Updated',
                    'New setpoint: ${setpointController.text}°C');
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildRecipeContainer({
    required String recipeName,
    required int recipeIndex,
    required BuildContext context,
  }) {
    RecipeController recipeController = Get.find<RecipeController>();
    String setpoint = RecipeController.recipeList[recipeIndex].setpoint;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        shape: const RoundedRectangleBorder(),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipeName,
                          style: TextStyle(
                            fontSize: 20,
                            color: colors['neutralTextColor']!,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Temperature Setpoint: $setpoint°C',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors['neutralTextColor']!.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<PopupItems>(
                    onSelected: (PopupItems item) {
                      int index = -1;
                      String targetName =
                          RecipeController.recipeList[recipeIndex].recipeName;
                      for (int i = 0;
                          i < RecipeController.recipeList.length;
                          i++) {
                        if (RecipeController.recipeList[i].recipeName ==
                            targetName) {
                          index = i;
                          break;
                        }
                      }
                      recipeController.recipeIndex.value = index;

                      if (item == PopupItems.edit) {
                        editSelectedRecipe(context);
                      } else if (item == PopupItems.run) {
                        showConfirmDialog(
                          context: context,
                          title: 'Run This Recipe',
                          text:
                              'Want to run ${RecipeController.recipeList[recipeController.recipeIndex.value].recipeName} recipe?',
                          onOkPressed: runrecipe,
                        );
                      } else if (item == PopupItems.editSP) {
                        editSetpoint(context);
                      } else {
                        showConfirmDialog(
                          context: context,
                          title: 'Delete Confirm',
                          text:
                              'Delete current recipe (${RecipeController.recipeList[recipeIndex].recipeName})?',
                          onOkPressed: deleteRecipe,
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<PopupItems>(
                          value: PopupItems.run,
                          child: Row(
                            children: [
                              Text('Run'),
                              Expanded(child: SizedBox(width: 10)),
                              Icon(
                                Icons.run_circle,
                                size: 20.0,
                              )
                            ],
                          ),
                        ),
                        const PopupMenuItem<PopupItems>(
                          value: PopupItems.edit,
                          child: Row(
                            children: [
                              Text('Edit Command'),
                              Expanded(child: SizedBox(width: 10)),
                              Icon(
                                Icons.edit,
                                size: 20.0,
                              )
                            ],
                          ),
                        ),
                        const PopupMenuItem<PopupItems>(
                          value: PopupItems.editSP,
                          child: Row(
                            children: [
                              Text('Edit Setpoint'),
                              Expanded(child: SizedBox(width: 10)),
                              Icon(
                                Icons.thermostat,
                                size: 20.0,
                              )
                            ],
                          ),
                        ),
                        const PopupMenuItem<PopupItems>(
                          value: PopupItems.delete,
                          child: Row(
                            children: [
                              Text('Delete'),
                              Expanded(child: SizedBox(width: 10)),
                              Icon(
                                Icons.delete,
                                size: 20.0,
                              )
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
