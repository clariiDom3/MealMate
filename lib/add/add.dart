import 'package:flutter/material.dart';
import 'package:mealmate/home/meal_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

final MealModel mealModel = MealModel();

class AddPage extends StatefulWidget {
  AddPage() {
    mealModel.loadData();
  }

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final Map<String, String> _selectedSubcategory = {};
  final Map<String, List<Meal>> _categoryMealOptions = {};
  final Map<String, Meal?> _selectedMeals = {};
  DateTime _selectedDate = DateTime.now();

  void _save(BuildContext context, MealModel model) async {
    for (var entry in model.finalMeals.entries) {
      Meal meal = entry.value!;
      List<int> nutrients = await setNutrients(meal);
      meal.date = model.selectedDate;
      meal.calories = nutrients[0];
      meal.protein = nutrients[1];
      meal.fat = nutrients[2];
      meal.carbs = nutrients[3];
    }

    await model.saveMeals();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Meal saved successfully!'),
      ),
    );
  }

  Future<List<int>> setNutrients(Meal meal) async {
    List<String> combinedIngredients = [];
    for (int i = 0; i < meal.measures!.length; i++) {
      final measures = meal.measures![i];
      final ingredient =
          (i < (meal.ingredients?.length ?? 0)) ? meal.ingredients![i] : '';
      combinedIngredients.add("$measures $ingredient");
    }
    return await meal.analyzeMealIngredients(combinedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MealModel>(
      model: mealModel,
      child: ScopedModelDescendant<MealModel>(
        builder: (context, child, model) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Add Meals',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color.fromARGB(255, 77, 167, 240),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  color: Colors.white,
                  onPressed: () => _save(context, model),
                ),
              ],
            ),
            body: Stack(
              children: [
                Container(
                  height: 350,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 77, 167, 240),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(200),
                      bottomRight: Radius.circular(200),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _calendar(model),
                    Flexible(child: _mealEntry(model)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _calendar(MealModel model) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat.yMMMMd().format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    model.setSelectedDate(picked);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4DA7F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mealEntry(MealModel model) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children:
              model.categoryMap.keys.map((category) {
                final subcategories = model.categoryMap[category]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children:
                              subcategories.map((subcat) {
                                final isSelected =
                                    _selectedSubcategory[category] == subcat;
                                return ChoiceChip(
                                  label: Text(subcat),
                                  selected: isSelected,
                                  onSelected: (_) async {
                                    setLocalState(() {
                                      _selectedSubcategory[category] = subcat;
                                      _categoryMealOptions[category] = [];
                                    });
                                    final meals = await model.fetchMeals(
                                      subcat,
                                    );
                                    setLocalState(() {
                                      _categoryMealOptions[category] = meals;
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedSubcategory[category] != null &&
                            _categoryMealOptions[category]?.isNotEmpty == true)
                          SizedBox(
                            height:
                                200, 
                            child: ListView.builder(
                              itemCount: _categoryMealOptions[category]!.length,
                              itemBuilder: (context, index) {
                                final meal =
                                    _categoryMealOptions[category]![index];
                                final isSelected =
                                    _selectedMeals[_selectedSubcategory[category]] ==
                                    meal;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        meal.imageUrl ?? '',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      ),
                                    ),
                                    title: Text(meal.name),
                                    tileColor:
                                        isSelected
                                            ? const Color.fromARGB(
                                              100,
                                              77,
                                              167,
                                              240,
                                            )
                                            : Colors.transparent,
                                    onTap: () {
                                      setLocalState(() {
                                        meal.mealType = category;
                                        _selectedMeals[_selectedSubcategory[category]!] =
                                            meal;
                                        model.finalMeals[category] = meal;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
