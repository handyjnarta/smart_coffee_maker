/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/command_controller.dart';
import '../custom_widget/custom_button.dart';
import 'add_device_view.dart';
import 'add_command_view.dart';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/command_controller.dart';
// import '../custom_widget/custom_button.dart';

class AddPouringView extends StatelessWidget {
  const AddPouringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final CommandController commandController = Get.find();

    // Placeholder calculation methods
    String calculateTotalWater(int index) {
      // Replace this with your actual calculation logic
      return '100 ml'; // Example value
    }

    String calculatePouringTime(int index) {
      // Replace this with your actual calculation logic
      return '5 seconds'; // Example value
    }

    String calculateWaitingTime(int index) {
      // Replace this with your actual calculation logic
      return '10 seconds'; // Example value
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pouring Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              int pouringSteps = int.tryParse(CommandController.commandCtrl.text) ?? 0;
              return Column(
                children: List.generate(pouringSteps, (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pouring Step ${index + 1}:'),
                      Text('Total Water: ${calculateTotalWater(index)}'),
                      Text('Pouring Time: ${calculatePouringTime(index)}'),
                      Text('Waiting Time: ${calculateWaitingTime(index)}'),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyCustomButton(
                  customWidget: const Text('Back'),
                  isCircleButton: false,
                  buttonWidth: 100,
                  onPressedAction: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 20),
                MyCustomButton(
                  customWidget: const Text('Save'),
                  isCircleButton: false,
                  buttonWidth: 100,
                  onPressedAction: () {
                    // Handle save action
                    // You can add the logic to save the pouring details here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/