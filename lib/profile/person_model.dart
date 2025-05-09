import 'package:scoped_model/scoped_model.dart';
import '../home/meal_model.dart';

class Person {
  String name;
  double goalWeight;
  double currentWeight;
  String height;
  int desiredCalories;
  int age;
  String gender;
  String? photoUrl;

  Person({
    required this.name,
    required this.goalWeight,
    required this.currentWeight,
    required this.height,
    required this.desiredCalories,
    required this.age,
    required this.gender,
    this.photoUrl,
  });
}

class PersonModel extends Model {
  int _index = 0;
  int get index => _index;

  bool isVegan = false;
  bool isPes = false;

  void toggleVegan() {
    isVegan = !isVegan;
    if (isVegan) isPes = false;
    notifyListeners();
  }

  void togglePes() {
    isPes = !isPes;
    if (isPes) isVegan = false;
    notifyListeners();
  }

  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  Person person = Person(
    name: 'Clarissa Dominguez',
    goalWeight: 160,
    currentWeight: 170,
    height: "5'6\"",
    desiredCalories: 1800,
    age: 23,
    gender: 'Female',
    photoUrl: null,
  );

  void updateField(String key, dynamic value) {
    switch (key) {
      case 'name':
        person.name = value;
        break;
      case 'goalWeight':
        person.goalWeight = value;
        break;
      case 'currentWeight':
        person.currentWeight = value;
        break;
      case 'height':
        person.height = value;
        break;
      case 'desiredCalories':
        person.desiredCalories = value;
        break;
      case 'age':
        person.age = value;
        break;
      case 'gender':
        person.gender = value;
        break;
      case 'photoUrl':
        person.photoUrl = value;
        break;
    }
    notifyListeners();
  }

  Future<List<Meal>> getFavoriteMeals() async {
    final favorites = await MealModel().getFavoriteMeals();
    return favorites;
  }

  Future<void> unfavoriteMeal(Meal meal) async {
    meal.isFavorite = 0;
    await MealModel().database.update(meal);
  }
}
