import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/providers/user_provider.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/dialog_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/widget/input_form_text_widget.dart';
import 'package:provider/provider.dart';

GlobalKey<FormState> _formKey = GlobalKey<FormState>();

UserProvider _userProvider;

String _username;
String _email;
String _password;

Pattern pattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
GlobalKey<ScaffoldState> _scaffoldKey;
RegExp regex = RegExp(pattern);

Widget loginWidget(BuildContext context, GlobalKey<FormState> formKey, GlobalKey<ScaffoldState> scaffoldKey) {
  _formKey = formKey;
  _scaffoldKey = scaffoldKey;
  return Form(
    key: _formKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: SizeConfig.heightMultiplier * 10,
          child: InputTextForm(
            label: AppStrings.emailHint,
            icon: Icons.mail_outline,
            inputType: TextInputType.emailAddress,
            validator: (String text) {
              if (text.isEmpty) {
                return AppStrings.errorEmailCannotBeEmptyLabel;
              } else if (!regex.hasMatch(text)) {
                return AppStrings.errorEmailNotValid;
              }
              _email = text;
              return null;
            },
          ),
        ),
        SizedBox(
          height: 4 * SizeConfig.heightMultiplier,
        ),
        Container(
          height: 10 * SizeConfig.heightMultiplier,
          child: InputTextForm(
            label: AppStrings.passwordHint,
            icon: Icons.lock_outline,
            isSecure: true,
            validator: (String text) {
              if (text.isEmpty) {
                return AppStrings.errorPasswordCannotBeEmptyLabel;
              } else if (text.length < 5) {
                return AppStrings.errorPasswordToShort;
              }
              _password = text;
              return null;
            },
          ),
        ),
        SizedBox(
          height: 4 * SizeConfig.heightMultiplier,
        ),
        MaterialButton(
          height: 7 * SizeConfig.heightMultiplier,
          textTheme: ButtonTextTheme.primary,
          elevation: 2,
          shape: StadiumBorder(),
          child: Text(
            AppStrings.logInButton,
            style: TextStyle(fontSize: SizeConfig.textMultiplier * 3),
          ),
          color: ColorProvider.primaryColor,
          onPressed: () {
            _submit('login', context);
          },
        ),
      ],
    ),
  );
}

Widget signUpWidget(BuildContext context, GlobalKey<FormState> formKey, GlobalKey<ScaffoldState> scaffoldKey) {
  _formKey = formKey;
  _scaffoldKey = scaffoldKey;
  return Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: SizeConfig.heightMultiplier * 13,
          child: InputTextForm(
              label: AppStrings.username,
              icon: Icons.person_outline,
              validator: (String text) {
                if (text.isEmpty) {
                  return AppStrings.errorUsernameCannotBeEmptyLabel;
                } else if (text.length < 4) {
                  return AppStrings.errorUsernameToShort;
                }
                _username = text;
                return null;
              }),
        ),
        Container(
          height: SizeConfig.heightMultiplier * 13,
          child: InputTextForm(
              label: AppStrings.emailHint,
              icon: Icons.mail_outline,
              inputType: TextInputType.emailAddress,
              validator: (String text) {
                if (text.isEmpty) {
                  return AppStrings.errorEmailCannotBeEmptyLabel;
                } else if (!regex.hasMatch(text)) {
                  return AppStrings.errorEmailNotValid;
                }
                _email = text;
                return null;
              }),
        ),
        Container(
          height: SizeConfig.heightMultiplier * 12,
          child: InputTextForm(
              label: AppStrings.passwordHint,
              icon: Icons.lock_outline,
              isSecure: true,
              validator: (String text) {
                if (text.isEmpty) {
                  return AppStrings.errorPasswordCannotBeEmptyLabel;
                } else if (text.length < 5) {
                  return AppStrings.errorPasswordToShort;
                }
                _password = text;
                return null;
              }),
        ),
        Container(
          height: SizeConfig.heightMultiplier * 7,
          child: MaterialButton(
            textTheme: ButtonTextTheme.primary,
            elevation: 2,
            shape: StadiumBorder(),
            child: Text(
              AppStrings.createAccountButton,
              style: TextStyle(fontSize: SizeConfig.textMultiplier * 3),
            ),
            color: ColorProvider.primaryColor,
            onPressed: () {
              _submit('signin', context);
            },
          ),
        ),
      ],
    ),
  );
}

Future _submit(String action, BuildContext context) async {
  final isValid = _formKey.currentState.validate();
  if (isValid) {
    DialogUtils.showLoadingDialog(context);
    NetworkHelper networkHelper = NetworkHelper();
    dynamic response;

    _formKey.currentState.save();

    switch (action.toUpperCase()) {
      case 'SIGNIN':
        response = await networkHelper.registerUser(username: _username, email: _email, password: _password);

        break;
      case 'LOGIN':
        response = await networkHelper.login(email: _email, password: _password);

        break;
    }

    if (response == 'true') {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _userProvider.data = await networkHelper.checkUser();
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(context, 'home', (Route<dynamic> route) => false);
    } else {
      Navigator.pop(context);
      DialogUtils.showMessageSnackBar(_scaffoldKey, AppStrings.errorLabel);
    }
  }
}
