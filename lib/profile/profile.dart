import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'person_model.dart'; 
import 'profile_view.dart';
import 'edit_profile.dart';
import 'favorites_page.dart';

PersonModel personModel = PersonModel();

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<PersonModel>(
      model: personModel,
      child: ScopedModelDescendant<PersonModel>(
        builder: (context, child, personModel) {
          return IndexedStack(
            index: personModel.index,
            children: <Widget>[
              ProfileView(),
              EditProfilePage(),
              FavoritesPage(),
            ],
          );
        },
      ),
    );
  }
}
