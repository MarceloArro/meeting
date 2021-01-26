import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/pages/login_signup_invite_page.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';

class MainInitialPage extends StatefulWidget {
  MainInitialPage({Key key}) : super(key: key);

  @override
  _MainInitialPageState createState() => _MainInitialPageState();
}

class _MainInitialPageState extends State<MainInitialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Styles.imgBackground,
        child: Container(
          color: ColorProvider.black.withOpacity(0.36),
          child: SafeArea(
            top: true,
            left: false,
            right: false,
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: <Widget>[
                  //top container with the logo
                  _topContainer(),
                  //middle container with the text
                  _middleContainer(),
                  //bottom container with the buttons
                  _bottomContainer(),
                  //sigInContainer bottom text
                  _signInContainer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //widget for top content
  Widget _topContainer() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 2),
          height: SizeConfig.imageSizeMultiplier * 50,
          child: Hero(tag: 'logo', child: Image.asset('assets/img/logo.png')),
          constraints: BoxConstraints(maxHeight: SizeConfig.imageSizeMultiplier * 50),
        ),
        Text(
          AppStrings.pageTitle,
          style: Styles.textTitle,
        ),
      ],
    );
  }

  //widget for middle content
  Widget _middleContainer() {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppStrings.welcome,
            style: Styles.textHintStart,
          ),
          Text(
            AppStrings.welcomeFriends,
            style: Styles.textFriends,
          ),
        ],
      ),
    );
  }

  //container with buttons that go to a new page but show different content
  //depending on the selected button
  Widget _bottomContainer() {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: SizeConfig.heightMultiplier * 10,
            child: CupertinoButton(
              child: Text(
                AppStrings.logInButton,
                style: TextStyle(fontSize: SizeConfig.textMultiplier * 3.5),
              ),
              color: ColorProvider.primaryColor,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginSignUpInvitePage(
                    isLoginPage: true,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: SizeConfig.heightMultiplier * 4,
          ),
          Container(
            height: SizeConfig.heightMultiplier * 11,
            child: CupertinoButton(
              child: Text(
                AppStrings.submitCode,
                style: TextStyle(fontSize: SizeConfig.textMultiplier * 3),
              ),
              color: ColorProvider.primaryLight,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginSignUpInvitePage(
                    isCodePage: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signInContainer(BuildContext context) {
    final _onTapGesture = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginSignUpInvitePage(
              isSignInPage: true,
            ),
          ),
        );
      };

    return Container(
      margin: EdgeInsets.only(top: SizeConfig.heightMultiplier * 6),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(text: AppStrings.noAccount, style: Styles.textColorWhiteMoreSize),
            TextSpan(text: " "),
            TextSpan(recognizer: _onTapGesture, text: AppStrings.createAccount, style: Styles.textPrimaryColor),
          ],
        ),
      ),
    );
  }
}
