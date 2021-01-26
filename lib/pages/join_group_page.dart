import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_app/models/user.dart';
import 'package:meeting_app/networks/constants_network.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/providers/user_provider.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/dialog_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';
import 'package:meeting_app/widget/input_form_text_widget.dart';
import 'package:provider/provider.dart';

import 'map_page.dart';

class JoinGroupPage extends StatefulWidget {
  final String groupId;

  const JoinGroupPage({Key key, this.groupId}) : super(key: key);

  @override
  _JoinGroupPageState createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final _formKey = GlobalKey<FormState>();
  UserProvider _userProvider;
  File _image;
  String _username;

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);
    return Container(
      decoration: Styles.imgBackground,
      child: Container(
        color: ColorProvider.black.withOpacity(0.36),
        child: Material(
          color: ColorProvider.transparent,
          child: Container(
            margin: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                AppBar(
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
                GestureDetector(
                  onTap: () => selectImage(),
                  child: CircleAvatar(
                    radius: SizeConfig.imageSizeMultiplier * 20,
                    backgroundColor: ColorProvider.primaryLight,
                    backgroundImage: _image != null ? FileImage(_image) : null,
                    child: _image != null
                        ? null
                        : Icon(
                            Icons.person,
                            size: SizeConfig.imageSizeMultiplier * 30,
                            color: ColorProvider.white,
                          ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.heightMultiplier * 10,
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    height: SizeConfig.heightMultiplier * 15,
                    child: InputTextForm(
                      label: 'Ingrese su nombre',
                      validator: (String text) {
                        if (text.isEmpty) {
                          return AppStrings.errorUsernameCannotBeEmptyLabel;
                        }
                        _username = text;
                        return null;
                      },
                    ),
                  ),
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  height: SizeConfig.heightMultiplier * 10,
                  child: Text(
                    "Ingresar".toUpperCase(),
                    style: Styles.textColorWhite,
                  ),
                  color: ColorProvider.primaryColor,
                  shape: StadiumBorder(),
                  onPressed: () => joinGroup(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectImage() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  void joinGroup() async {
    bool validation = _formKey.currentState.validate();
    if (validation) {
      DialogUtils.showLoadingDialog(context);
      User user = User(username: _username);
      if (_image != null) {
        final imagePath = await NetworkHelper().updateAvatar(path: NetworkConstants.API_AVATAR_INVITED, image: _image);
        if (imagePath != null) {
          user.avatar = imagePath;
        }
      }

      _userProvider.data = user;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MapPage(
            groupId: widget.groupId,
            invited: true,
          ),
        ),
      );
    }
  }
}
