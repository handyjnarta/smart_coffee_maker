
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

enum PopupItems { edit, delete, run }

// ignore: must_be_immutable
class RecipesView extends StatelessWidget {
  const RecipesView({Key? key}) : super(key: key);
  //int index = 1;

  void runrecipe() {
    Navigator.pop(Get.context!);
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

      // if (RecipeController().isSaveRecipeBtnClicked() == false) {
      //   debugPrint('[recipe_view] old recipe rolled back');
      //   RecipeController
      //           .recipeList[RecipeController().recipeIndex.value].commandList =
      //       RecipeController().oldRecipeData['oldRecipe']['commandList'];
      //   ctrl.refreshLogs(
      //       text:
      //           'Recipe "${RecipeController.recipeList[RecipeController().recipeIndex.value].recipeName}" editing canceled');
      //   showGetxSnackbar('Cancel to edit',
      //       'Recipe "${RecipeController.recipeList[RecipeController().recipeIndex.value].recipeName}" editing canceled');
      // }
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

  Widget buildRecipeContainer({
    required String recipeName,
    //required bool status,
    required int recipeIndex,
    required BuildContext context,
  }) {
    RecipeController recipeController = Get.find<RecipeController>();
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
                    child: Text(

                      recipeName,
                      style: TextStyle(
                          fontSize: 20, color: colors['neutralTextColor']!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<PopupItems>(
                    onSelected: (PopupItems item) {
                      // RecipeController().recipeIndex.value = RecipeController
                      //      .recipeList
                      //       .indexWhere((dev) => dev.recipeName == RecipeController.recipeList[recipeIndex].recipeName);
                      int index = -1;
                      String targetName =
                          RecipeController.recipeList[recipeIndex].recipeName;
                      for (int i = 0;
                          i < RecipeController.recipeList.length;
                          i++) {
                        if (RecipeController.recipeList[i].recipeName ==
                            targetName) {
                          index = i;
                          //debugPrint('dapet nih: $index');
                          break;
                        }
                      }
                      //debugPrint('kayanya ada error: $index');

                      //recipeController.recipeIndex.value = RecipeController().recipeIndex.value;
                      recipeController.recipeIndex.value = index;
                      debugPrint(
                          'index resep: ${recipeController.recipeIndex.value}');
                      debugPrint(
                          'nama resep: ${RecipeController.recipeList[recipeController.recipeIndex.value].recipeName}');
                      //int indexRecipe = int.parse(RecipeController.recipeList[recipeIndex].recipeName);
                      //RecipeController().recipeIndex.value = indexRecipe;

                      if (item == PopupItems.edit) {
                        editSelectedRecipe(context);
                      } else if (item == PopupItems.run) {
                        showConfirmDialog(
                          context: context,
                          title: 'Run This recipe',
                          text:
                              'Want to run ${RecipeController.recipeList[recipeController.recipeIndex.value].recipeName} recipe ?',
                          onOkPressed: runrecipe,
                        );
                      } else {
                        showConfirmDialog(
                          context: context,
                          title: 'Delete confirm',
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
                              Text('Edit'),
                              Expanded(child: SizedBox(width: 10)),
                              Icon(
                                Icons.edit,
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
