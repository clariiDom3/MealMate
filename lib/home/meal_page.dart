import 'package:flutter/material.dart';
import 'package:mealmate/home/meal_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MealPage extends StatelessWidget {
  const MealPage({super.key});

  String? extractYoutubeId(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MealModel>(
      builder: (BuildContext context, Widget? child, MealModel model) {
        if (model.meal == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("No Meal Selected"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => model.setIndex(0),
                color: Colors.white, // Go back to the home view
              ),
              backgroundColor: Color.fromARGB(255, 77, 167, 240),
            ),
            backgroundColor: Colors.white,
            body: const Center(child: Text("No meal data available.")),
          );
        }
        Meal meal = model.meal!;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => model.setIndex(0),
              color: Colors.white,
            ),
            backgroundColor: Color.fromARGB(255, 77, 167, 240),
            actions: [
              IconButton(
                icon: Icon(
                  meal.isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
                  color: meal.isFavorite == 1 ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  final newValue = meal.isFavorite == 1 ? 0 : 1;
                  model.setFavorite(newValue);
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [_photo(meal), _mealDetails(meal, context)],
            ),
          ),
        );
      },
    );
  }

  Widget _photo(Meal meal) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 77, 167, 240),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                meal.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    meal.imageUrl!,
                    fit: BoxFit.cover,
                    height: 200,
                    width: 300,
                  ),
                )
                : const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
          ],
        ),
      ),
    );
  }

  Widget _mealDetails(Meal meal, BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nutrition Facts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Calories: ${meal.calories ?? 0} kcal"),
            Text("Protein: ${meal.protein ?? 0}g"),
            Text("Carbs: ${meal.carbs ?? 0}g"),
            Text("Fats: ${meal.fat ?? 0}g"),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ingredients and Measures",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(meal.ingredients != null && meal.measures != null
                ? List.generate(meal.ingredients!.length, (index) {
                  final ingredient = meal.ingredients![index];
                  final measure =
                      index < meal.measures!.length
                          ? meal.measures![index]
                          : '';
                  return Text("- $measure $ingredient");
                })
                : [const Text("No ingredients listed.")]),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Instructions",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(meal.instructions ?? "No instructions provided."),
            ],
          ),
        ),
        if (meal.youtubeUrl != null && meal.youtubeUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Watch Recipe Video",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(meal.youtubeUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Could not open the video."),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://img.youtube.com/vi/${extractYoutubeId(meal.youtubeUrl)}/0.jpg",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            // exportShoppingList(meal);
          },
          icon: const Icon(Icons.share),
          label: const Text("Export Shopping List"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
