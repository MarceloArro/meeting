class Group {
  String description;
  List<String> members;
  String id;
  String groupName;
  String owner;
  String imgUrl;

  Group({this.description,
    this.members,
    this.id,
    this.groupName,
    this.owner,
    this.imgUrl});

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        description: json["description"],
        members: List<String>.from(json["members"].map((x) => x)),
        id: json["_id"],
        groupName: json["groupName"],
        owner: json["owner"],
    imgUrl: json["imgUrl"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "members": List<dynamic>.from(members.map((x) => x)),
        "_id": id,
        "groupName": groupName,
        "owner": owner,
    "imgUrl": imgUrl,
      };
}
