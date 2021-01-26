import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';
import 'package:meeting_app/widget/invite_member_widget.dart';
import 'package:meeting_app/widget/login_singup_widget.dart';

class LoginSignUpInvitePage extends StatefulWidget {
  final bool isCodePage;
  final bool isLoginPage;
  final bool isSignInPage;
  final String routePath;

  LoginSignUpInvitePage(
      {Key key, this.isCodePage = false, this.isLoginPage = false, this.isSignInPage = false, this.routePath})
      : super(key: key);

  @override
  _LoginSignUpInvitePageState createState() => _LoginSignUpInvitePageState();
}

class _LoginSignUpInvitePageState extends State<LoginSignUpInvitePage> {
  bool isSigIn = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Styles.imgBackground,
      child: Container(
        color: ColorProvider.black.withOpacity(0.36),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: ColorProvider.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(SizeConfig.heightMultiplier * 6),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: ColorProvider.transparent,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: ColorProvider.white,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: <Widget>[
                  _topContainer(),
                  _middleTextContainer(),
                  _displayContainer(),
                  widget.isSignInPage || isSigIn ? Container() : signInOptionBottom(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topContainer() {
    return Column(
      children: <Widget>[
        Container(
          child: Hero(tag: 'logo', child: Image.asset('assets/img/logo.png')),
          constraints: BoxConstraints(
            maxHeight: SizeConfig.imageSizeMultiplier * 30,
          ),
        ),
        Text(
          AppStrings.pageTitle,
          style: TextStyle(color: ColorProvider.primaryColor, fontSize: SizeConfig.textMultiplier * 4),
        ),
      ],
    );
  }

  //widget for middle content
  Widget _middleTextContainer() {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 8, bottom: SizeConfig.heightMultiplier * 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            widget.isLoginPage
                ? AppStrings.logInButton
                : widget.isCodePage
                    ? AppStrings.addCode
                    : AppStrings.createAccountTitle,
            style: Styles.textHintStart,
          ),
          Text(widget.isCodePage ? "Para unirte a un grupo" : AppStrings.addInfo, style: Styles.textFriends),
        ],
      ),
    );
  }

  Widget _displayContainer() {
    if (widget.isSignInPage || isSigIn) return signUpWidget(context, _formKey, _scaffoldKey);
    if (widget.isLoginPage) return loginWidget(context, _formKey, _scaffoldKey);
    if (widget.isCodePage) return AddCodeWidget(inviteCode: "5d0cd67904542c7473e67bef5b831dbbce826f781576185651883");
    return Container();
  }

  Widget signInOptionBottom() {
    final _onTapGesture = TapGestureRecognizer()
      ..onTap = () {
        _formKey?.currentState?.reset();
        isSigIn = true;
        setState(() {});
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
