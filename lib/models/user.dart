class User {
  String email;
  String username;
  String avatar;
  String uid;
  List<String> groups;

  User({
    this.email,
    this.username,
    this.avatar,
    this.uid,
    this.groups,
  });

  User.fromJson(Map<String, dynamic> json) {
    this.groups = List<String>.from(json["groups"].map((x) => x));
    this.email = json['email'];
    this.username = json['username'];
    this.avatar = json['avatar'];
    this.uid = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groups'] = List<dynamic>.from(groups.map((x) => x));
    data['email'] = this.email;
    data['username'] = this.username;
    data['avatar'] = this.avatar;
    data['_id'] = this.uid;
    return data;
  }
}
