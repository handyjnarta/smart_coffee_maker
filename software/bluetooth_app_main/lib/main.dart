import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/controllers/recipe_controller.dart';
import 'app/controllers/global_controller.dart';
import 'app/views/main_view.dart';
import 'bluetooth_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

DateTime? currentBackPressTime;
late Controller ctrl;
late ScrollController listScrollController;
late SharedPreferences prefs;

void main() async {
  Get.lazyPut(() => RecipeController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Force sign out the user on startup
  //await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[main] building UI');
    ctrl = Get.put(Controller());
    // Listen to BluetoothData messages
    BluetoothData.instance.messageStream.listen((message) {
      debugPrint('Received message: $message');
      // Add your code here to process the message
    });

    return GetMaterialApp(
      title: 'Flutter Bluetooth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          debugPrint('[StreamBuilder] Checking authentication state');
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('[StreamBuilder] Waiting for authentication state');
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint(
                '[StreamBuilder] Error in authentication state: ${snapshot.error}');
            return const Center(
                child: Text(
                    'Error occurred while checking authentication status'));
          } else if (snapshot.hasData) {
            debugPrint('[StreamBuilder] User is authenticated');
            return const BluetoothApp();
          } else {
            debugPrint('[StreamBuilder] User is not authenticated');
            return Login();
          }
        },
      ),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({super.key});

  @override
  BluetoothAppState createState() => BluetoothAppState();
}

class BluetoothAppState extends State<BluetoothApp>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    debugPrint('[BluetoothApp] Initializing');
    ctrl.initTabController(this);
    init();

    listScrollController = ScrollController(initialScrollOffset: 50.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (listScrollController.hasClients) {
        listScrollController.animateTo(
            listScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('[BluetoothApp] Disposing');
    BluetoothData.instance.dispose();
    listScrollController.dispose();
    super.dispose();
  }

  Future init() async {
    prefs = await SharedPreferences.getInstance();
    RecipeController().loadRecipeListFromStorage();
    await BluetoothData.instance.initBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus
            ?.unfocus(), // to hide keyboard if the screen tapped outside of the keyboard
        child: const MainView());
  }
}

Future<bool> onWillPop() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
    currentBackPressTime = now;
    showGetxSnackbar("Exit app", "Press again to exit");
    return Future.value(false);
  }
  return Future.value(true);
}
