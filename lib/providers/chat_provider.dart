import 'package:flutter/material.dart';
import 'package:meeting_app/models/message.dart';
import 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = List();

  List<Message> get messages => _messages;

  set messages(List<Message> value) {
    _messages = value;
    notifyListeners();
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  int indexMessage(Message message) {
    return _messages.indexOf(message);
  }

  void removeMessage(int index) {
    _messages.removeAt(index);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  static ChatProvider of(BuildContext context) => Provider.of<ChatProvider>(context);
}
