import 'package:flutter/material.dart';
import 'package:mealmate/home/meal_model.dart';
import 'package:scoped_model/scoped_model.dart';

class MealList extends StatelessWidget {
  const MealList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MealModel>(
      builder: (context, child, model) {
        return FutureBuilder<List<Meal>>(
          future: model.getMealsByTheDate(model.selectedDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Center(child: Text("no meals"))],
                ),
              );
            }
            final meals = snapshot.data!;
            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "Today's Meals",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...meals
                              .map(
                                (meal) => _buildMealCard(context, model, meal),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        //final meals = getMealsForDate(model.selectedDate);
      },
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    MealModel model,
    Meal selectedMeal,
  ) {
    return GestureDetector(
      onTap: () {
        print('Tapped: ${selectedMeal.name}');
        model.goToMealPage(selectedMeal);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 77, 167, 240),
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedMeal.mealType ?? 'no name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(selectedMeal.name, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
