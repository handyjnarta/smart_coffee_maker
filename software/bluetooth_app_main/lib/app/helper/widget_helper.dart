import 'package:flutter/material.dart';

ButtonStyle buildButtonStyle(
    {Color borderColor = Colors.purple,
    bool isCircleButton = false,
    Color? splashColor,
    double? radiusSize,
    double? buttonWidth}) {
  return ButtonStyle(
    // minimumSize: WidgetStateProperty.all(Size.fromWidth(buttonWidth ?? 40)),
    minimumSize: WidgetStateProperty.all(Size(buttonWidth ?? 40, 40)),
    shape: WidgetStateProperty.all(isCircleButton
        ? const CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusSize ?? 30)))),
    padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
    // backgroundColor: WidgetStateProperty.all(Colors.blue), // <-- Button color
    side: WidgetStateProperty.all(BorderSide(
      color: borderColor,
    )),
    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return splashColor ??
            Colors
                .deepPurple; // <-- Splash color / if splashColor is null then return deepPurple
      }
      return null;
    }),
  );
}

Widget buildTextField({required String title,
  String? errorText,
  required String commandText,
  required TextEditingController commandTextController,
  bool isReadOnly=false,
  VoidCallback? onChanged
}) {
  return
    TextField(
      onChanged: (value) {
        onChanged?.call();
      },

      readOnly: isReadOnly,
      autofocus: false,
      controller: commandTextController,
      decoration: InputDecoration(
          errorText: errorText,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: errorText == null || errorText.length < 3 ? Colors.grey : Colors.red, width: 1.0),
          ),

          focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              // borderSide: BorderSide(width: 1,color: DeviceController.errorText.value.length < 3 ? Colors.black : Colors.red)
              borderSide: BorderSide(width: 1,
                  color: errorText == null || errorText.length < 3
                  ? Colors.grey
                  : Colors.red
              )
          ),

          // hintText: commandTextController.text,
          hintText: commandText,
          floatingLabelBehavior: isReadOnly ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
          labelText: title,
          labelStyle: const TextStyle(
            color: Colors.black
          ),
          isDense: true,
          contentPadding: const EdgeInsets.all(12),
          // contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: const OutlineInputBorder()
      ),
    );
}