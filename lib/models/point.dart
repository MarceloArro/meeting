import 'package:flutter_map/flutter_map.dart';

class Points {
  double latitude;
  double longitude;
  String userId;
  String userName;

  Marker marker;

  Points(
      {this.latitude, this.longitude, this.userId, this.userName, this.marker});

  Points.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    userId = json['userId'];
    userName = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['userId'] = this.userId;
    data['username'] = this.userName;
    return data;
  }
}
