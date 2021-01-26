import 'package:flutter/material.dart';
import 'package:meeting_app/models/group.dart';

class GroupProvider extends ChangeNotifier {
  List<Group> _groups = List();

  List<Group> get groups => _groups;

  set groups(List<Group> value) {
    _groups = value;
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void removeGroup(int index) {
    _groups.removeAt(index);
    notifyListeners();
  }

  void editGroup(int index, Group group) {
    _groups[index] = group;
    notifyListeners();
  }

  void clearGroups() {
    _groups.clear();
    notifyListeners();
  }

  Group getGroup(String groupId) {
    return _groups.firstWhere((group) => group.id == groupId);
  }
}
