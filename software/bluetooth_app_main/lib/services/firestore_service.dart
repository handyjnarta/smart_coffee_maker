import 'package:cloud_firestore/cloud_firestore.dart';
import '../app/models/recipes.dart'; // Ensure you have the correct import path for your Recipes class
import '../../app/models/commands.dart'; // Ensure you have the correct import path for your Commands class

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveRecipesListIntoFirestore(List<Recipes> recipeList) async {
    for (final recipe in recipeList) {
      final recipeData = {
        'recipeName': recipe.recipeName,
        'id': recipe.id,
        'status': recipe.status,
        'setpoint': recipe.setpoint,
        'commandList': recipe.commandList.map((cmd) => cmd.toJson()).toList(),
      };
      await _db.collection('recipes').doc(recipe.recipeName).set(recipeData);
    }
  }

  Future<List<Recipes>> loadRecipesListFromFirestore() async {
    final querySnapshot = await _db.collection('recipes').get();
    List<Recipes> allRecipes = [];
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      List<Commands> commandList = (data['commandList'] as List)
          .map((cmdData) => Commands.fromJson(cmdData))
          .toList();
      allRecipes.add(Recipes(
        recipeName: data['recipeName'],
        id: data['id'],
        status: data['status'],
        setpoint: data['setpoint'],
        commandList: commandList,
      ));
    }
    return allRecipes;
  }
}
