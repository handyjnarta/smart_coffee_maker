import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recipe_controller.dart';
import '../helper/widget_helper.dart';

class MyCustomButton extends StatelessWidget {
  final VoidCallback? onPressedAction;
  final String? commandNumStep;
  final Widget customWidget;
  final Color? borderColor;
  final bool? isCircleButton;
  final double? radiusSize;
  final double? buttonWidth;

  const MyCustomButton({
    Key? key,
    required this.customWidget,
    required this.onPressedAction,
    this.borderColor,
    this.commandNumStep,
    this.isCircleButton,
    this.radiusSize,
    this.buttonWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the RecipeController instance
    final RecipeController recipeController = Get.find<RecipeController>();

    return OutlinedButton(
      onPressed: () {
        if (commandNumStep != null) {
          debugPrint('');
          debugPrint('[widget_helper]commandnumsteps: $commandNumStep');
          recipeController.selectedNumSteps = commandNumStep!;
          debugPrint(
              '[widget_helper]selectednumsteps: ${recipeController.selectedNumSteps}');
        }

        onPressedAction?.call();

        if (recipeController.isEditRecipe.value ||
            recipeController.isInsertNewRecipe.value) {
          recipeController.refreshSaveRecipeButtonState();
        }
      },
      style: buildButtonStyle(
        borderColor: borderColor ?? Colors.grey,
        isCircleButton: isCircleButton ?? true,
        radiusSize: radiusSize,
        buttonWidth: buttonWidth,
      ),
      child: customWidget,
    );
  }
}
