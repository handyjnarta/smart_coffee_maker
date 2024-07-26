import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/command_controller.dart';
import 'package:flutter_bluetooth/app/helper/widget_helper.dart';
import '../custom_widget/custom_button.dart';

class CommandMenu extends StatelessWidget {
  late final String numStep;
  late final String volume;
  late final String timePouring;
  late final String timeInterval;
  late final bool readOnly;
  late final VoidCallback? onDeleteButtonPressed;
  late final VoidCallback? onEditButtonPressed;
  CommandMenu({
    Key? key,
    this.readOnly = false,
    this.onEditButtonPressed,
    this.onDeleteButtonPressed,
    required String numStep,
    required String volume,
    required String timeInterval,
    required String timePouring,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildDeviceCommandMenu(
      numStep: numStep,
      volume: volume,
      timeInterval: timeInterval,
      timePouring: timePouring,
      isTextEditingReadOnly: readOnly,
      onEditButtonPressed: onEditButtonPressed,
      onDeleteButtonPressed: onDeleteButtonPressed,
    );
  }

  // set setNewCommandMenuTitle(String newTitle) => titleText = newTitle;

  Widget buildDeviceCommandMenu({
    required String numStep,
    required String volume,
    required String timeInterval,
    required String timePouring,
    bool isTextEditingReadOnly = false,
    void Function()? onEditButtonPressed,
    void Function()? onDeleteButtonPressed,
  }) {
    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: SizedBox(
                  width: 220,
                  height: 40,
                  child: buildTextField(
                  title: 'Pouring Steps',
                  commandText: CommandController.commandCtrl.text,
                  errorText: CommandController.commandErrorText.value,
                  commandTextController: CommandController.commandCtrl,
                  ),
                ),
              ),
              MyCustomButton(
                commandTitle: "Edit Command", // or any relevant title
                customWidget: const Icon(Icons.edit),
                onPressedAction: onEditButtonPressed,
              ),
              MyCustomButton(
                commandTitle: "Delete Command", // or any relevant title
                customWidget: const Icon(Icons.delete),
                onPressedAction: onDeleteButtonPressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
