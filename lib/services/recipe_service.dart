// imports
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeService {
  // where recipes are stored in JSON
  static const _key = 'recipe';

  Future<List<Recipe>> loadAll() async {
    // load all recipes from storage
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    // return empty list if nothing is stored
    if (data == null || data.isEmpty) return [];

    // return list with recipes data
    return (jsonDecode(data) as List).map((e) => Recipe.fromJson(e)).toList();
  }

  Future<void> save(Recipe recipe) async {
    // load all recipes from strogage
    final prefs = await SharedPreferences.getInstance();
    final recipes = await loadAll();

    // add new recipe and save to storage
    recipes.add(recipe);
    await prefs.setString(
      _key,
      jsonEncode(recipes.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> delete(String id) async {
    // load all recipes from storage
    final prefs = await SharedPreferences.getInstance();
    final recipes = await loadAll();

    // remove recipe with correct id & save back to storage
    recipes.removeWhere((r) => r.id == id);
    await prefs.setString(
      _key,
      jsonEncode(recipes.map((r) => r.toJson()).toList()),
    );
  }
}
