import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'person_model.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PersonModel>(
      builder: (context, child, model) {
        final p = model.person;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Profile"),
            leading: IconButton(
              icon: const Icon(Icons.save),
              onPressed:
                  () => model.setIndex(
                    0,
                  ), // Set the index to 0 to go back to the home view
              color: Colors.white,
            ),
            backgroundColor: const Color.fromARGB(255, 77, 167, 240),
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _buildTextField(model, 'name', p.name),
                _buildTextField(model, 'goalWeight', p.goalWeight.toString()),
                _buildTextField(
                  model,
                  'currentWeight',
                  p.currentWeight.toString(),
                ),
                _buildTextField(model, 'height', p.height),
                _buildTextField(
                  model,
                  'desiredCalories',
                  p.desiredCalories.toString(),
                ),
                _buildTextField(model, 'age', p.age.toString()),
                _buildTextField(model, 'gender', p.gender),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(PersonModel model, String field, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: field,
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          final parsed = double.tryParse(val);
          if (field == 'goalWeight' || field == 'currentWeight') {
            model.updateField(field, parsed ?? 0);
          } else if (field == 'desiredCalories' || field == 'age') {
            model.updateField(field, int.tryParse(val) ?? 0);
          } else {
            model.updateField(field, val);
          }
        },
      ),
    );
  }
}
