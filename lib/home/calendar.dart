import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:mealmate/home/meal_model.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MealModel>(
      builder: (BuildContext context, Widget? child, MealModel model) {
        return Scaffold(
          appBar: AppBar(
            title: Text(DateFormat('MMMM d, y').format(model.selectedDate)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                model.setIndex(0);
              },
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: 40),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: CalendarCarousel<Event>(
                    thisMonthDayBorderColor: Colors.grey,
                    daysHaveCircularBorder: false,
                    onDayPressed: (DateTime date, List<Event> events) {
                      model.setSelectedDate(date);
                      model.setIndex(0);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
