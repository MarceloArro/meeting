class Message {
  String text;
  String userName;
  String avatar;
  String type;
  bool myMessage;

  Message({this.text,
    this.userName,
    this.type,
    this.myMessage = false,
    this.avatar});

  Message.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    userName = json['username'];
    type = json['type'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['text'] = this.text;
    data['username'] = this.userName;
    data['type'] = this.type;
    data['avatar'] = this.avatar;
    return data;
  }
}

//TODO: change clipOval to ClipRRect
// TODO : Rewview SPACER

