import 'package:flutter/material.dart';
import 'package:mealmate/home/meal_model.dart';
import 'package:mealmate/profile/person_model.dart';
import 'package:scoped_model/scoped_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PersonModel>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Favorite Meals"),
            backgroundColor: const Color.fromARGB(255, 77, 167, 240),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => model.setIndex(0),
              color: Colors.white,
            ),
          ),
          body: FutureBuilder<List<Meal>>(
            future: model.getFavoriteMeals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final meals = snapshot.data ?? [];
              if (meals.isEmpty) {
                return const Center(child: Text("No favorites yet."));
              }
              return ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Card(
                    child: ListTile(
                      title: Text(meal.name),
                      subtitle: Text(meal.category ?? ''),
                      leading:
                          meal.imageUrl != null
                              ? Image.network(
                                meal.imageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : const Icon(Icons.image),
                      trailing: Icon(Icons.favorite, color: Colors.red),
                      onTap: () async {
                        await model.unfavoriteMeal(meal);
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
