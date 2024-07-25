// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import '/services/firestore_service.dart';
import 'commands.dart';

class Recipes {
  String recipeName;
  String id;
  int setpoint;
  bool status;
  List<Commands> commandList;

  Recipes({
    required this.recipeName,
    required this.id,
    required this.status,
    required this.setpoint,
    required this.commandList,
  });

  Map<String, dynamic> toJson() => {
        "recipeName": recipeName,
        "id": id,
        "status": status,
        "setpoint": setpoint,
        "commandList": commandList.map((cmd) => cmd.toJson()).toList(),
      };

  static Recipes fromJson(Map<String, dynamic> json) => Recipes(
        recipeName: json["recipeName"],
        id: json["id"],
        status: json["status"],
        setpoint: json["setpoint"],
        commandList: (json["commandList"] as List)
            .map((cmd) => Commands.fromJson(cmd))
            .toList(),
      );

  set setNewRecipe(String newRecipeName) => recipeName = newRecipeName;
}

class RecipesManager {
  // Singleton
  RecipesManager._privateConst();
  static final RecipesManager instance = RecipesManager._privateConst();
  factory RecipesManager() => instance;

  final FirestoreService _firestoreService = FirestoreService();
  final List<bool> _statusList = [];

  List<bool> get getStatusRecipesList => _statusList;

  int get getRecipesCount => _statusList.length;

  Future<void> saveRecipesListIntoFirestore(List<Recipes> recipesList) async {
    await _firestoreService.saveRecipesListIntoFirestore(recipesList);
  }

  Future<List<Recipes>> loadRecipesListFromFirestore() async {
    final allRecipes = await _firestoreService.loadRecipesListFromFirestore();
    _statusList.clear();
    for (final recipe in allRecipes) {
      _statusList.add(recipe.setpoint as bool);
    }
    return allRecipes;
  }
}
