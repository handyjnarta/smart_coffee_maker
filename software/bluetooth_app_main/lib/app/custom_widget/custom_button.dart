//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import '../controllers/recipe_controller.dart';
import '../helper/widget_helper.dart';

class MyCustomButton extends StatelessWidget {
  final VoidCallback? onPressedAction;
  // final void Function()? onPressedAction;
  final String? commandTitle;
  final Widget customWidget;
  final Color? borderColor;
  final bool? isCircleButton;
  final double? radiusSize;
  final double? buttonWidth;
  const MyCustomButton(
      {Key? key,
      required this.customWidget,
      required this.onPressedAction,
      this.borderColor,
      this.commandTitle,
      this.isCircleButton,
      this.radiusSize,
      this.buttonWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          if (commandTitle != null) {
            debugPrint('');
            debugPrint('[widget_helper]commandTitle: $commandTitle');
            RecipeController().selectedTitle.value = commandTitle!;
          }

          onPressedAction?.call();

          if (RecipeController().isEditRecipe.value ||
              RecipeController().isInsertNewRecipe.value) {
            RecipeController().refreshSaveRecipeButtonState();
          }
          // onPressedAction;
        },
        style: buildButtonStyle(
            borderColor: borderColor ?? Colors.grey,
            isCircleButton: isCircleButton ?? true,
            radiusSize: radiusSize,
            buttonWidth: buttonWidth),
        child: customWidget);
  }
}
