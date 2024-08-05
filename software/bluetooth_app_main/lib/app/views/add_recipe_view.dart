import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/constant/constant.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
import 'package:flutter_bluetooth/app/views/add_command_view.dart';
import 'package:flutter_bluetooth/utils.dart';
import 'package:get/get.dart';
import '../helper/widget_helper.dart';
import '../helper/popup_dialogs.dart';

class AddRecipeView extends StatelessWidget {
  final String title;

  const AddRecipeView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Get.find to access the controller instance
    final RecipeController recipeController = Get.find<RecipeController>();

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 250),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.deepPurple,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField(
                        title: 'Recipe Name',
                        commandText: RecipeController.recipeNameController.text,
                        errorText: recipeController.errorText.value,
                        commandTextController:
                            RecipeController.recipeNameController,
                        onChanged:
                            recipeController.refreshNewCommandButtonState,
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 14.0),
                            child: Text(
                              'Commands:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const Expanded(child: SizedBox(width: 20)),
                          OutlinedButton(
                            onPressed: () {
                              // Get the current RecipeController instance
                              //final recipeController =
                              //Get.find<RecipeController>();

                              // Check if the recipe name is empty
                              if (RecipeController
                                  .recipeNameController.text.isEmpty) {
                                // Set the error text if the recipe name is not provided
                                recipeController.errorText.value =
                                    'Recipe name is required';
                                debugPrint('Error: Recipe name is required');
                              } else if (recipeController
                                  .enableNewCommandBtn.isTrue) {
                                // Proceed to create a new command if the button is enabled
                                createNewCommand(context, recipeController);
                                debugPrint('createNewCommand called');
                              } else {
                                final recipeName =
                                    RecipeController.recipeNameController.text;
                                debugPrint(
                                    'createNewCommand not called. Recipe name: $recipeName');
                              }
                            },
                            style: buildButtonStyle(
                                borderColor: Colors.grey, buttonWidth: 80),
                            child: const Text('New Command'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...CommandController.commandMenuList
                          .map((commandMenu) => commandMenu)
                          .toList(),
                      const Divider(thickness: 2),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // Atur jarak antar tombol
                        children: [
                          saveButton(context, recipeController),
                          cancelButtonRecipe(context, recipeController),
                        ],
                      )
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

/*
  Widget buildTextField({
    required String title,
    required String commandText,
    required String errorText,
    required TextEditingController commandTextController,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        TextField(
          controller: commandTextController,
          onChanged: onChanged,
          decoration: InputDecoration(
            errorText: errorText.isEmpty ? null : errorText,
          ),
        ),
      ],
    );
  }
*/
  Widget saveButton(BuildContext context, RecipeController recipeController) {
    return SizedBox(
      width: 200,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          if (RecipeController.currentRecipe == null ||
              RecipeController.currentRecipe!.commandList.length <
                  minCommandCount) {
            showCustomDialog(
              context: context,
              actionList: standardPopupItems(
                  contentText:
                      'Please add at least $minCommandCount command(s)'),
              title: 'Command < $minCommandCount',
            );
          } else {
            recipeController.saveRecipeData();
            Navigator.pop(context);
            //Navigator.pop(context);
          }
        },
        style: buildButtonStyle(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save),
            SizedBox(width: 10),
            Text('Save Recipe'),
          ],
        ),
      ),
    );
  }

  Widget cancelButtonRecipe(
      BuildContext context, RecipeController recipeController) {
    return SizedBox(
      width: 100,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
          CommandController.currentStep.value = 0;
          RecipeController().refreshNewCommandButtonState();
          RecipeController().refreshSaveRecipeButtonState();
        },
        style: buildButtonStyle(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel),
            SizedBox(width: 10),
            Text('Cancel'),
          ],
        ),
      ),
    );
  }

  void createNewCommand(
      BuildContext context, RecipeController recipeController) {
    recipeController.onNewCommandButtonPressed();

    showCustomDialog(
      context: context,
      actionList: [const CommandView()],
      title: 'Create New Command',
    );
  }

  //static void editCommand(BuildContext buildContext) {}
}
