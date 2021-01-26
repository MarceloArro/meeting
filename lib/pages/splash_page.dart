//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/pages/home_page.dart';
import 'package:meeting_app/pages/login_signup_invite_page.dart';
import 'package:meeting_app/pages/main_initial_page.dart';
import 'package:meeting_app/providers/user_provider.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  UserProvider _userProvider;

  @override
  void initState() {
    initDynamicLinks();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    BoxConstraints constraints = BoxConstraints(maxHeight: height, maxWidth: width);
    SizeConfig().init(constraints);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: Styles.imgBackground,
              child: Opacity(
                opacity: 0.42,
                child: Container(
                  decoration: Styles.splashGradient,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5 * SizeConfig.heightMultiplier,
                left: 2 * SizeConfig.heightMultiplier,
                right: 2 * SizeConfig.heightMultiplier,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Image.asset(
                        "assets/img/logo_white.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 2 * SizeConfig.heightMultiplier),
                        child: Text(
                          AppStrings.pageTitle,
                          style: Styles.textTitleSplash,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: EdgeInsets.only(top: 2 * SizeConfig.heightMultiplier),
                        child: CupertinoActivityIndicator(
                          radius: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initDynamicLinks() async {
    Uri deepLink;

    //final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    // deepLink = data?.link;

    //router(deepLink);

    //FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
    // deepLink = dynamicLink?.link;

    router(deepLink);
  }

  void router(Uri dynamicLink) async {
    final user = await NetworkHelper().checkUser();
    _userProvider.data = user;

    if (dynamicLink != null) {
      if (user != null) {
        Navigator.pushReplacement(
          (context),
          MaterialPageRoute(
            builder: (context) => HomePage(
              dynamicLink: dynamicLink.toString(),
            ),
          ),
        );
        return;
      } else {
        Navigator.pushReplacement(
          (context),
          MaterialPageRoute(
            builder: (context) {
              return LoginSignUpInvitePage(
                isCodePage: true,
                routePath: dynamicLink.toString(),
              );
            },
          ),
        );
        return;
      }
    } else {
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));

        return;
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainInitialPage()));
//        Navigator.of(context).pushReplacement(
//          (_),
//          MaterialPageRoute(
//            builder: (context) => MainInitialPage(),
//          ),
//        );
      }
    }
  }
}
