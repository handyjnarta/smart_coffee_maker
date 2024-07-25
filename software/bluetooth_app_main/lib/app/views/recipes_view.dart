import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:get/get.dart';
import '../../bluetooth_data.dart';
import '../../main.dart';
import '../../utils.dart';
import '../constant/constant.dart';
import 'add_recipe_view.dart';

enum PopupItems { edit, delete }

class RecipesView extends StatelessWidget {
  const RecipesView({Key? key}) : super(key: key);

  void deleteRecipe() {
    // Get.back();
    Navigator.pop(Get.context!);
    String recipeName =
        RecipeController.recipeList[RecipeController.recipeIndex].recipeName;
    RecipeController.recipeList.removeAt(RecipeController.recipeIndex);
    ctrl.refreshLogs(text: 'Recipe "$recipeName" deleted');
    // showSnackBar('Recipe deleted');
    showGetxSnackbar('Recipe deleted', 'Recipe "$recipeName" deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RecipeController.recipeList.isNotEmpty
          ? ListView.builder(
              itemCount: RecipeController.recipeList.length,
              itemBuilder: (BuildContext context, int index) {
                debugPrint('[recipe_view] rebuilding listview');

                return buildRecipeContainer(
                    context: context,
                    recipeName: RecipeController.recipeList[index].recipeName,
                    status: RecipeController.recipeList[index].status,
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
    RecipeController.editRecipe();

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
          '[recipe_view] RecipeController.isSaveRecipeBtnClicked: ${RecipeController.isSaveRecipeBtnClicked}');
      // jika show modal bottom sheet closed, cek apakah ditutup karena tombol save recipe di klik atau bukan
      // jika bukan karena tombol save di klik, maka kembalikan data recipe yang lama karena recipe yang diedit tidak disimpan

      if (RecipeController.isSaveRecipeBtnClicked == false) {
        debugPrint('[recipe_view] old recipe rolled back');
        RecipeController.recipeList[RecipeController.recipeIndex].commandList =
            RecipeController.oldRecipeData['oldRecipe']['commandList'];
        ctrl.refreshLogs(
            text:
                'Recipe "${RecipeController.recipeList[RecipeController.recipeIndex].recipeName}" editing canceled');
        showGetxSnackbar('Cancel to edit',
            'Recipe "${RecipeController.recipeList[RecipeController.recipeIndex].recipeName}" editing canceled');
      }
    });
  }

  void createNewRecipe(BuildContext context) {
    RecipeController.createNewRecipe();

    // add new recipe
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),

        // to make bottom sheet move up when keyboard active if the keyboard hover of textfield
        // reference: https://stackoverflow.com/a/59005853
        // - wrap column with SingleChildScrollView
        // - wrap SingleChildScrollView with Padding --> padding: MediaQuery.of(context).viewInsets,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return const AddRecipeView(title: 'Add new recipe');
        }).whenComplete(() {
      debugPrint(
          '[recipe_view] show modal bottom sheet closed (insert new recipe)');
      // jika show modal bottom sheet closed, cek apakah ditutup karena tombol save recipe di klik atau bukan
      // jika bukan karena tombol save di klik, maka hapus recipe yang baru dibuat (jika ada)
    });
  }

  buildRecipeContainer(
      {required String recipeName,
      required bool status,
      required int recipeIndex,
      required BuildContext context}) {
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

                  // to turned on button
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('[recipes_view] To turn On Command: r');

                      if (ctrl.isConnected.isTrue) {
                        BluetoothData.instance
                            .sendMessageToBluetooth('r', false);
                        RecipeController.recipeList[recipeIndex].status = true;
                        RecipeController.recipeList.refresh();
                      }
                    },
                    child: const Text("ON"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),

                  const SizedBox(
                    width: 10,
                  ),
                  PopupMenuButton<PopupItems>(onSelected: (PopupItems item) {
                    RecipeController.recipeIndex = RecipeController.recipeList
                        .indexWhere((dev) => dev.recipeName == recipeName);

                    if (item == PopupItems.edit) {
                      editSelectedRecipe(context);
                    } else {
                      // delete the selected recipe
                      showConfirmDialog(
                        context: context,
                        title: 'Delete confirm',
                        text: 'Delete current recipe ($recipeName)?',
                        onOkPressed: deleteRecipe,
                      );
                    }
                  }, itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<PopupItems>(
                        value: PopupItems.edit,
                        child: Row(
                          children: [
                            Text('Edit'),
                            Expanded(
                                child: SizedBox(
                              width: 10,
                            )),
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
                            Expanded(
                                child: SizedBox(
                              width: 10,
                            )),
                            Icon(
                              Icons.delete,
                              size: 20.0,
                            )
                          ],
                        ),
                      ),
                    ];
                  })
                ],
              ),
              // Text(description)
            ],
          ),
        ),
      ),
    );
  }
}
