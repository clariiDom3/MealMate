import 'package:flutter/material.dart';
import 'package:mealmate/home/home_view.dart';
import 'package:mealmate/home/meal_model.dart';
import 'package:mealmate/home/meal_page.dart';
import 'calendar.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatelessWidget {
  HomePage() {
    mealModel.loadData();
  }

  final MealModel mealModel = MealModel(); // Define mealModel instance

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MealModel>(
      model: mealModel,
      child: ScopedModelDescendant<MealModel>(
        builder: (BuildContext context, Widget? child, MealModel mealModel) {
          return IndexedStack(
            index: mealModel.index,
            children: <Widget>[HomeView(), MealPage(), Calendar()],
          );
        },
      ),
    );
  }
}
