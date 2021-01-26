import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/tooltip_utils.dart' as uTip;

class MarkerItems extends StatelessWidget {
  final String name;

  const MarkerItems({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: uTip.Tooltip(
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Image.asset(
              "assets/img/location_marker.png",
              fit: BoxFit.cover,
              color: ColorProvider.primaryColor,
            ),
            //CircleAvatar(backgroundColor: ColorProvider.secondaryDark,),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          color: ColorProvider.blackOpacity,
        ),
        message: name != null ? name : "Tu ubicacion",
        preferBelow: false,
        verticalOffset: 30.0,
      ),
    );
  }
}
