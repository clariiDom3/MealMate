import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealmate/home/meal_list.dart';
import 'package:mealmate/home/meal_model.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MealModel>(
      builder: (context, child, model) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 77, 167, 240),
          body: SafeArea(
            child: Column(
              children: [_calendar(model), Expanded(child: MealList())],
            ),
          ),
        );
      },
    );
  }

  Widget _calendar(MealModel model) {
    String today = DateFormat('EEEE').format(model.selectedDate);
    String fullDate = DateFormat('MMMM d, y').format(model.selectedDate);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              model.setIndex(2);
            },
            child: Column(
              children: [
                Text(
                  fullDate,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
                Text(
                  today,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
