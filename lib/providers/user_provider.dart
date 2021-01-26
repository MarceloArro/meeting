import 'package:flutter/material.dart';
import 'package:meeting_app/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _data;

  User get data => _data;

  set data(User user) {
    this._data = user;
    notifyListeners();
  }
}

//de splah verifica usuario, si no esta en el provider va a login
// de login pasa a splash y como ya esta el usuario cargado pasa a home
// es para no hacerlo en el login de nuevo
