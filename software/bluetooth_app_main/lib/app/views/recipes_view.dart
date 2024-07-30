import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
//import 'package:flutter_bluetooth/app/controllers/global_controller.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:get/get.dart';
import '../../bluetooth_data.dart';
import '../../main.dart';
import '../../utils.dart';
import '../constant/constant.dart';
import 'add_recipe_view.dart';

enum PopupItems { edit, delete, run }

class RecipesView extends StatelessWidget {
  const RecipesView({Key? key}) : super(key: key);

  void runrecipe() {
    String recipeName = RecipeController()
        .recipeList[RecipeController().recipeIndex.value]
        .recipeName;
    showGetxSnackbar('Recipe deleted', 'Recipe "$recipeName" ran now');
    double setpointval = 0.0;
    int numstepsval = 0;
    int volumeval = 0;
    int timeIntervalval = 0;
    int timePouringval = 0;
    ctrl.changeTab(1);
    String message = 'r';
    BluetoothData().sendMessageToBluetooth(message, true);
    message = setpointval as String;
    BluetoothData().sendMessageToBluetooth(message, true);
    message = numstepsval as String;
    BluetoothData().sendMessageToBluetooth(message, true);
    for (int i = 0; i < numstepsval; i++) {
      volumeval = 0; // masukin untuk volume val di index numstepval nya
      message = volumeval as String;
      BluetoothData().sendMessageToBluetooth(message, true);
      timePouringval =
          0; // masukin untuk timePouring val di index numstepval nya
      message = timePouringval as String;
      BluetoothData().sendMessageToBluetooth(message, true);
      timeIntervalval =
          0; // masukin untuk timeInterval val di index numstepval nya
      message = timeIntervalval as String;
      BluetoothData().sendMessageToBluetooth(message, true);
    }
  }

  void deleteRecipe() {
    Navigator.pop(Get.context!);
    String recipeName = RecipeController()
        .recipeList[RecipeController().recipeIndex.value]
        .recipeName;
    RecipeController()
        .recipeList
        .removeAt(RecipeController().recipeIndex.value);
    ctrl.refreshLogs(text: 'Recipe "$recipeName" deleted');
    showGetxSnackbar('Recipe deleted', 'Recipe "$recipeName" deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return (RecipeController().recipeList.isNotEmpty)
          ? ListView.builder(
              itemCount: RecipeController().recipeList.length,
              itemBuilder: (BuildContext context, int index) {
                debugPrint('[recipe_view] rebuilding listview');
                return buildRecipeContainer(
                    context: context,
                    recipeName: RecipeController().recipeList[index].recipeName,
                    status: RecipeController().recipeList[index].status,
                    recipeIndex: index);
              })
          : const Center(
              child: Text(
              'No recipe found mmk',
              style: TextStyle(fontSize: 22),
            ));
    });
  }

  void editSelectedRecipe(BuildContext context) {
    RecipeController().editRecipe();

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

      if (RecipeController().isSaveRecipeBtnClicked == false) {
        debugPrint('[recipe_view] old recipe rolled back');
        RecipeController()
                .recipeList[RecipeController().recipeIndex.value]
                .commandList =
            RecipeController().oldRecipeData['oldRecipe']['commandList'];
        ctrl.refreshLogs(
            text:
                'Recipe "${RecipeController().recipeList[RecipeController().recipeIndex.value].recipeName}" editing canceled');
        showGetxSnackbar('Cancel to edit',
            'Recipe "${RecipeController().recipeList[RecipeController().recipeIndex.value].recipeName}" editing canceled');
      }
    });
  }

  void createNewRecipe(BuildContext context) {
    RecipeController().createNewRecipe();
    AddRecipeView.editCommand(context);
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
    required bool status,
    required int recipeIndex,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: status
                ? colors['onBorderColor']!
                : colors['neutralBorderColor']!,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
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
                      RecipeController().recipeIndex.value = RecipeController()
                          .recipeList
                          .indexWhere((dev) => dev.recipeName == recipeName);

                      if (item == PopupItems.edit) {
                        editSelectedRecipe(context);
                      } else if (item == PopupItems.run) {
                        showConfirmDialog(
                          context: context,
                          title: 'Run This recipe',
                          text: 'Want to run ($recipeName) recipe ?',
                          onOkPressed: runrecipe,
                        );
                      } else {
                        showConfirmDialog(
                          context: context,
                          title: 'Delete confirm',
                          text: 'Delete current recipe ($recipeName)?',
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
