import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meeting_app/pages/home_page.dart';
import 'package:meeting_app/pages/join_group_page.dart';
import 'package:meeting_app/pages/login_signup_invite_page.dart';
import 'package:meeting_app/pages/main_initial_page.dart';
import 'package:meeting_app/pages/map_page.dart';
import 'package:meeting_app/pages/profile_page.dart';
import 'package:meeting_app/pages/splash_page.dart';
import 'package:meeting_app/providers/chat_provider.dart';
import 'package:meeting_app/providers/group_provider.dart';
import 'package:meeting_app/providers/point_provider.dart';
import 'package:meeting_app/providers/user_provider.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PointsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupProvider(),
        ),
        Provider<GlobalKey<ScaffoldState>>.value(value: GlobalKey<ScaffoldState>()),
      ],
      //materialApp
      child: MaterialApp(
        locale: Locale('es', 'CL'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('es'),
        ],
        debugShowCheckedModeBanner: false,
        title: '${AppStrings.pageTitle}',
        theme: ThemeData(
            primaryColor: ColorProvider.primaryColor,
            primaryColorDark: ColorProvider.primaryDark,
            primaryColorLight: ColorProvider.primaryLight,
            accentColor: ColorProvider.secondaryColor),
        home: SplashPage(),
        routes: {
          "splash": (context) => SplashPage(),
          "home": (context) => HomePage(),
          "map": (context) => MapPage(),
          "main": (context) => MainInitialPage(),
          "profile": (context) => ProfilePage(),
          "loginSiguCode": (context) => LoginSignUpInvitePage(),
          "joinGroup": (context) => JoinGroupPage(),
        },
      ),
    );
  }
}
