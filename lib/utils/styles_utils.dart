import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';

abstract class Styles {
  //background
  static const imgBackground = BoxDecoration(
    image: DecorationImage(
      image: ExactAssetImage('assets/img/background_img.jpg'),
      fit: BoxFit.cover,
    ),
  );

  static const splashGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        ColorProvider.secondaryColor,
        ColorProvider.secondaryLight,
      ],
    ),
  );

  //InputStyles
  static OutlineInputBorder focusedInput = OutlineInputBorder(
    borderRadius: new BorderRadius.circular(14),
    borderSide: BorderSide(color: ColorProvider.secondaryLight),
  );
  static const enabledInput = OutlineInputBorder(
    borderSide: BorderSide(color: ColorProvider.primaryLight),
  );
  static const errorInput = OutlineInputBorder(
    borderSide: BorderSide(color: ColorProvider.red),
  );

  //text styles
  static TextStyle textColorWhite = TextStyle(color: ColorProvider.white, fontSize: SizeConfig.textMultiplier * 2);

  static TextStyle textColorWhiteMoreSize =
      TextStyle(color: ColorProvider.white, fontSize: SizeConfig.textMultiplier * 2.5);

  static TextStyle textTitleSplash = TextStyle(
    fontSize: SizeConfig.textMultiplier * 5.5,
    color: ColorProvider.white,
  );

  static TextStyle textTitle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 5.5,
    color: ColorProvider.primaryColor,
  );

  static TextStyle textHintStart = TextStyle(
    fontSize: SizeConfig.textMultiplier * 5,
    color: ColorProvider.primaryColor,
  );
  static TextStyle textFriends = TextStyle(
    fontSize: SizeConfig.textMultiplier * 3.5,
    color: ColorProvider.white,
  );

  static TextStyle textPrimaryColorMoreSize = TextStyle(
    color: ColorProvider.secondaryColor,
    fontSize: SizeConfig.textMultiplier * 3,
  );

  static TextStyle textPrimaryColor =
      TextStyle(color: ColorProvider.primaryColor, fontSize: SizeConfig.textMultiplier * 2.5);
}
