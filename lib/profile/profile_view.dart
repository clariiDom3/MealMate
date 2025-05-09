import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'person_model.dart';
import '../home/meal_model.dart';

final MealModel mealModel = MealModel();

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PersonModel>(
      builder: (context, child, model) {
        return FutureBuilder<List<Meal>>(
          future:
              model.getFavoriteMeals(), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              ); 
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              ); 
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromARGB(255, 77, 167, 240),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.white,
                      onPressed:
                          () => model.setIndex(1), // Navigate to edit view
                    ),
                  ],
                ),
                body: const Center(child: Text("No favorite meals available.")),
              );
            } else {
              final favoriteMeals = snapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromARGB(255, 77, 167, 240),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.white,
                      onPressed:
                          () => model.setIndex(1), // Navigate to edit view
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
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    model.person.photoUrl != null
                                        ? AssetImage(model.person.photoUrl!)
                                        : null,
                                child:
                                    model.person.photoUrl == null
                                        ? const Icon(
                                          Icons.person_2_outlined,
                                          size: 50,
                                          color: Colors.black,
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 30),
                              Text(
                                model.person.name,
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Age: ${model.person.age}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Gender: ${model.person.gender}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 28),
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(32),
                              ),
                              border: Border.all(color: Colors.blueGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "Height: ${model.person.height}",
                                  style: const TextStyle(fontSize: 17),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Weight: ${model.person.currentWeight}",
                                  style: const TextStyle(fontSize: 17),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Goal Weight: ${model.person.goalWeight}",
                                  style: const TextStyle(fontSize: 17),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Calories/day: ${model.person.desiredCalories}",
                                  style: const TextStyle(fontSize: 17),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Progress: ${((model.person.goalWeight / model.person.currentWeight) * 100).clamp(0, 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 17),
                                ),
                                const SizedBox(height: 18),
                                LinearProgressIndicator(
                                  value: (model.person.goalWeight /
                                          model.person.currentWeight)
                                      .clamp(0, 1),
                                  minHeight: 12,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color.fromARGB(255, 77, 167, 240),
                                      ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          preferences(model, context),
                          const SizedBox(height: 20),
                          favoriteMeal(model, favoriteMeals),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Container preferences(PersonModel model, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        border: Border.all(color: Colors.blueGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Are you vegan?", style: TextStyle(fontSize: 18)),
              Switch(
                value: model.isVegan,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  model.toggleVegan();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Are you pescatarian?",
                style: TextStyle(fontSize: 18),
              ),
              Switch(
                value: model.isPes,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  model.togglePes();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector favoriteMeal(PersonModel model, final favoriteMeals) {
    return GestureDetector(
      onTap: () {
        model.setIndex(2);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          border: Border.all(color: Colors.blueGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Favorite Meals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (favoriteMeals.isEmpty)
              const Text("No favorites yet.")
            else
              ...favoriteMeals.map((meal) => Text("- ${meal.name}")).toList(),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
