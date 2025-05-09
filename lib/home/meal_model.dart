import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../base_model.dart';
import '../meal_db_worker.dart';
import 'package:http/http.dart' as http;

class Meal extends Entry {
  int id = 0;
  int? calories;
  int? protein;
  int? fat;
  int? carbs;
  String name = '';
  String? imageUrl;
  String? category;
  String? area;
  String? instructions;
  String? youtubeUrl;
  List<String>? ingredients;
  List<String>? measures;
  int? isFavorite = 0;
  DateTime? date;
  String? mealType;

  Meal({
    required this.id,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    required this.name,
    this.imageUrl,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.ingredients,
    this.measures,
    this.isFavorite,
    this.date,
    this.mealType,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty &&
          measure != null &&
          measure.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measures.add(measure.toString().trim());
      }
    }

    return Meal(
      id:
          int.tryParse(json['idMeal'] ?? '0') ??
          0,
      name: json['strMeal'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      imageUrl: json['strMealThumb'],
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  Future<List<int>> analyzeMealIngredients(List<String> ingredients) async {
    final String response = await rootBundle.loadString('assets/foods.json');
    final Map<String, dynamic> jsonData = json.decode(response);
    final List<dynamic> foods = jsonData['FoundationFoods'] ?? [];

    int totalCalories = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarbs = 0;

    for (String ingredient in ingredients) {
      final data = _findBestMatch(ingredient, foods);
      if (data != null) {
        final List nutrients = data['foodNutrients'];
        int getValue(String name) {
          final match = nutrients.firstWhere(
            (n) =>
                n['nutrient']['name'].toString().toLowerCase() ==
                name.toLowerCase(),
            orElse: () => null,
          );
          return (match?['amount'] as num?)?.round() ?? 0;
        }

        final protein = (getValue('Protein') as num?)?.round() ?? 0;
        final fat = (getValue('Total lipid (fat)') as num?)?.round() ?? 0;
        final carbs =
            (getValue('Carbohydrate, by difference') as num?)?.round() ?? 0;
        final calories =
            (getValue('Energy') as num?)?.round() ??
            (protein * 4 + fat * 9 + carbs * 4);

        totalProtein += protein;
        totalFat += fat;
        totalCarbs += carbs;
        totalCalories += calories;
      } else {
        print('"$ingredient" not found.');
      }
    }

    return [totalCalories, totalProtein, totalFat, totalCarbs];
  }

  String _cleanIngredient(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), '').trim();
  }

  Map<String, dynamic>? _findBestMatch(String ingredient, List<dynamic> foods) {
    final cleaned = _cleanIngredient(ingredient);

    for (var item in foods) {
      final desc = (item['description'] ?? '').toString().toLowerCase();
      if (desc.contains(cleaned)) return item;
    }

    for (var item in foods) {
      final desc = (item['description'] ?? '').toString().toLowerCase();
      if (cleaned.split(' ').any((word) => desc.contains(word))) {
        return item;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchNutrientData(String ingredient) async {
    final String response = await rootBundle.loadString('assets/foods.json');
    final Map<String, dynamic> jsonData = json.decode(response);
    final List<dynamic> foods = jsonData['FoundationFoods'] ?? [];

    for (var item in foods) {
      final description = item['description']?.toString().toLowerCase() ?? '';
      if (description.contains(ingredient.toLowerCase())) {
        return item;
      }
    }
    return null;
  }
}

class MealModel extends BaseModel<Meal> {
  MealModel() : super(MealDBWorker.db);

  Meal? meal;
  List<Meal> allMeals = [];
  Map<String, Meal?> finalMeals = {};
  Map<String, List<String>> categoryMap = {
    'Breakfast': ['Breakfast', 'Eggs', 'Pancakes'],
    'Lunch': ['Beef', 'Chicken', 'Pasta', 'Fish'],
    'Dinner': ['Seafood', 'Lamb', 'Pork', 'Fish'],
    'Snacks': ['Yogurt', 'Fruit'],
  };

  int _index = 0;
  DateTime _selectedDate = DateTime.now();
  int isFavorite = 0;

  int get index => _index;
  DateTime get selectedDate => _selectedDate;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  void setFavorite(int favorite) async {
    print(meal!.name);
    if (meal != null) {
      meal!.isFavorite = favorite;
      await database.update(meal!);
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setIndex(int value) {
    _index = value;
    notifyListeners();
  }

  @override
  void loadData() async {
    allMeals = await fetchAllMeals();
    entryList.clear();
    entryList.addAll(await database.getAll());
    notifyListeners();
  }

  void goToMealPage(Meal selectedMeal) {
    meal = selectedMeal;
    index = 1;
    notifyListeners();
  }

  Future<List<Meal>> getFavoriteMeals() async {
    return await database.getFavorites();
  }

  Future<int?> saveMeals() async {
    int? lastId;
    for (var entry in finalMeals.entries) {
      Meal meal = entry.value!;
      meal.date = selectedDate;
      meal.mealType = entry.key; 
      final existing = await database.getMealByDateAndType(
        meal.date!,
        meal.mealType!,
      );
      if (existing != null) {
        print("Updating ${meal.mealType} for ${meal.date}");
        meal.id = existing.id;
        await database.update(meal);
        lastId = meal.id;
      } else {
        print("Inserting new ${meal.mealType} for ${meal.date}");
        lastId = await database.create(meal);
      }
    }
    loadData();
    finalMeals = {};
    return lastId;
  }

  Future<List<Meal>> getMealsByTheDate(DateTime theDate) async {
    List<Meal> meals = await database.getMealByDate(theDate);
    if (meals.isEmpty) {
      return [];
    }
    return meals;
  }

  Future<List<Meal>> fetchMeals(String query) async {
    List<Meal> meals =
        allMeals
            .where(
              (meal) => (meal.name).toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    if (meals.isEmpty) {
      throw Exception('Failed to load meals');
    } else {
      return meals;
    }
  }

  Future<List<Meal>> fetchAllMeals() async {
    for (
      var charCode = 'a'.codeUnitAt(0);
      charCode <= 'z'.codeUnitAt(0);
      charCode++
    ) {
      final letter = String.fromCharCode(charCode);
      final url =
          'https://www.themealdb.com/api/json/v1/1/search.php?f=$letter';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mealsJson = data['meals'] as List?;

        if (mealsJson != null) {
          for (var json in mealsJson) {
            final meal = Meal.fromJson(json);
            final exists = allMeals.any((m) => m.id == meal.id);
            if (!exists) {
              allMeals.add(meal);
            }
          }
        }
      } else {
        throw Exception('Failed to fetch meals for letter $letter');
      }
    }
    return allMeals;
  }
}
