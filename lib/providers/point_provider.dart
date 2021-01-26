import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:meeting_app/models/point.dart';
import 'package:provider/provider.dart';

class PointsProvider extends ChangeNotifier {
  List<Marker> _markerList = List();

  List<Marker> get markerList => _markerList;

  set markerList(List<Marker> value) {
    _markerList = value;
    notifyListeners();
  }

  List<Points> _markerPoints = List();

  List<Points> get markerPoints => _markerPoints;

  set marketPoints(List<Points> value) {
    _markerPoints = value;
    notifyListeners();
  }

  void addPoint(Points point) {
    _markerPoints.add(point);
    if (point.marker != null) {
      _markerList.add(point.marker);
    }
    notifyListeners();
  }

  void removePoint(int index) {
    _markerPoints.removeAt(index);
    _markerList.removeAt(index);

    notifyListeners();
  }

  void clearPoint() {
    _markerPoints.clear();
    _markerList.clear();
    notifyListeners();
  }

  void clearMarkers() {
    _markerList.clear();
    notifyListeners();
  }

  void clearAll() {
    _markerList.clear();
    _markerPoints.clear();
  }

  int getPointIndex(Points point) {
    return _markerPoints.indexOf(point);
  }

  int getMarkerIndex(Marker marker) {
    return _markerList.indexOf(marker);
  }

  Points filterPointAndGetPoint(String id) {
    return _markerPoints.firstWhere((point) => point.userId == id && point.marker != null, orElse: () => null);
  }

  static PointsProvider of(BuildContext context) => Provider.of<PointsProvider>(context);
}
