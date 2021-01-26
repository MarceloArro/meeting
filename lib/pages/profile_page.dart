import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:meeting_app/networks/constants_network.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/providers/user_provider.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/dialog_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //create a [KeyboardVisibilityNotification] that notify if the keyboard is visible or not
  KeyboardVisibilityNotification _keyboardVisibility = new KeyboardVisibilityNotification();

  //Keys
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //Providers
  UserProvider userProvider;

  //variable of the position of the [AnimatedPositioned] with initial value of the middle of screen
  double containerPosition = SizeConfig.heightMultiplier * 50;

  //Subscription of the [KeyboardVisibility
  int _keyboardVisibilitySubscriberId;

  //variable to check and determinate the edit mode
  bool isEnabled = false;

  //manage the focus on the [TextFormField]
  FocusNode _focusNode;

  //variable of the displayed icon with the initial [IconData] of edit
  IconData _icon = Icons.edit;

  //variables of the user information
  String _email;
  String _username;
  String _password;
  String message;
  File _image;

  //show a [BottomSheet] and manage the different actions
  void selectImage() async {
    //changes the focus of the [TextFormField]
    FocusScope.of(context).requestFocus(FocusNode());

    //show the [BottomSheet]
    _scaffoldKey.currentState.showBottomSheet((context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          //invisible part of the [BottomSheet]
          //hat cover all top part of the screen to dismiss the [BottomSheet]
          Expanded(
            flex: 9,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),

          //Bottom part of the sheet that have different actions
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: ColorProvider.black,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //message text of the top of the container
                  Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      AppStrings.profilePhoto,
                      style: TextStyle(color: ColorProvider.white, fontSize: SizeConfig.textMultiplier * 3),
                    ),
                  ),
                  //Row with all the actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //Camera action
                      Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            margin: EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: ColorProvider.secondaryColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.photo_camera),
                              color: ColorProvider.white,
                              onPressed: () async {
                                _image = await ImagePicker.pickImage(source: ImageSource.camera);
                                Navigator.pop(context);
                                setState(() {});
                                _updateProfileImage();
                              },
                            ),
                          ),
                          Text(
                            AppStrings.camera,
                            style: Styles.textColorWhite,
                          ),
                        ],
                      ),
                      //upload photo action
                      Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            margin: EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: ColorProvider.primaryColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.image),
                              color: ColorProvider.white,
                              onPressed: () async {
                                _image = await ImagePicker.pickImage(source: ImageSource.gallery);
                                Navigator.pop(context);
                                setState(() {});
                                _updateProfileImage();
                              },
                            ),
                          ),
                          Text(
                            AppStrings.gallery,
                            style: Styles.textColorWhite,
                          ),
                        ],
                      ),
                      //delete photo action
                      Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            margin: EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: ColorProvider.red,
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              color: ColorProvider.white,
                              onPressed: () {
                                _updateProfileImage(delete: true);
                              },
                            ),
                          ),
                          Text(
                            AppStrings.deletePhoto,
                            style: Styles.textColorWhite,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      //transparent color to the [BottomSheet]
    }, backgroundColor: ColorProvider.transparent);
  }

  //manage the update photos in the [user.avatar]
  void _updateProfileImage({bool delete = false}) async {
    //get the [token] of the user to manage the changes
    final token = await NetworkHelper().getAccessToken();

    //variable to manage the different response of the server
    dynamic imageUrl;
    //check the [delete] action
    if (delete) {
      //if the action is true delete the [user.avatar] on the server
      imageUrl = await NetworkHelper().deleteAvatar();
    } else {
      //if the action is false manage the action on a [updateAvatar] action
      //update the [user.avatar] on the server
      imageUrl =
          await NetworkHelper().updateAvatar(path: NetworkConstants.API_AVATAR_USER, image: _image, token: token);
    }
    //manage the response [imgURl] value and check if the value is [null]
    if (imageUrl != null) {
      //check response result
      if (imageUrl == 'true') {
        Navigator.pop(context);
        //manage the [SnackBar] message
        message = "Foto eliminada";
        //change the [UserProvider] avatar value
        userProvider.data.avatar = null;
        _image = null;
        setState(() {});
      }
      //if the message ist not true but is different to null
      else {
        //manage the [SnackBar] message
        message = "Imagen modificada";
        //change the [UserProvider] avatar value
        userProvider.data.avatar = imageUrl;
      }
    } else {
      //manage the [SnackBar] message
      message = AppStrings.errorLabel;
    }
    //show the [SnackBar] with the message
    DialogUtils.showMessageSnackBar(_scaffoldKey, message);
  }

  //save the [Form] and send the data
  void _validateForm() async {
    //save the [Form]
    _formKey.currentState.save();

    //send the data
    final response = await NetworkHelper().updateUser(email: _email, username: _username, password: _password);

    //check the response value
    if (response != null) {
      //manage the message
      message = AppStrings.userModified;
      //change the [UserProvider] data
      userProvider.data = response;
    } else {
      //manage the message
      message = AppStrings.errorLabel;
    }
    //reset the form
    _formKey.currentState.reset();
    //show [SnackBar] with the message
    DialogUtils.showMessageSnackBar(_scaffoldKey, message);
  }

  void saveEditProfileUserButton() {
    //check the value of [isEnabled]
    if (!isEnabled) {
      setState(() {
        //change the icon
        _icon = Icons.save;
        //change the value [isEnabled]
        isEnabled = true;
        //change the position of [AnimatedContainer]
        containerPosition = SizeConfig.heightMultiplier * 30;
        //dismiss the focus
        FocusScope.of(context).requestFocus(_focusNode);
      });
    } else {
      setState(() {
        //change the icon
        _icon = Icons.edit;
        //change the value [isEnabled]
        isEnabled = false;
        //change the position of [AnimatedContainer]
        containerPosition = SizeConfig.heightMultiplier * 50;
        //save and validate the [Form] to send the data
        _validateForm();
      });
    }
  }

  //on InitState
  @override
  void initState() {
    super.initState();
    //create the [FocusNode]
    _focusNode = FocusNode();
    //add a listener to the [_keyboardVisibility]
    //and modify the value of the [_keyboardVisibilitySubscriberId]
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        //on change event in the [_keyboardVisibility]
        if (visible) {
          setState(() {
            //modify the position of the [AnimatedPositioned]
            containerPosition = SizeConfig.heightMultiplier * 30;
          });
        } else {
          setState(() {
            //modify the position of the [AnimatedPositioned]
            containerPosition = SizeConfig.heightMultiplier * 50;
          });
        }
      },
    );
  }

  //on dispose
  @override
  void dispose() {
    //dispose the focus
    _focusNode?.dispose();
    //remove the subscription
    _keyboardVisibility?.removeListener(_keyboardVisibilitySubscriberId);
    super.dispose();
  }

  //build
  @override
  Widget build(BuildContext context) {
    //Provider
    userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            //top container of background image
            _backgroundImage(),
            //appBar of the page
            _appTopBar(),
            //bottom Positioned with animation
            AnimatedPositioned(
              curve: Curves.linearToEaseOut,
              duration: Duration(milliseconds: 400),
              top: containerPosition,
              //bottom container of Positioned
              child: Container(
                width: SizeConfig.widthMultiplier * 100,
                height: SizeConfig.heightMultiplier * 140 - containerPosition,
                padding: EdgeInsets.only(top: 32, left: 16, right: 32),
                decoration: BoxDecoration(
                  color: ColorProvider.white,
                  boxShadow: [
                    BoxShadow(
                      color: ColorProvider.black,
                      blurRadius: 24.0,
                      spreadRadius: 8,
                      offset: Offset(0, 10),
                    )
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Container(
                  child: _profileForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundImage() {
    return Container(
      alignment: Alignment.center,
      height: SizeConfig.heightMultiplier * 62,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: _image != null
                ? FileImage(_image)
                : userProvider.data.avatar != null
                    ? NetworkImage("${NetworkConstants.HOST}/${userProvider.data.avatar}")
                    : AssetImage("assets/img/icon_person.png"),
            fit: BoxFit.fill),
      ),
    );
  }

  Widget _appTopBar() {
    return AppBar(
      title: Text(AppStrings.profileToolTip),
      backgroundColor: ColorProvider.transparent,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () => selectImage(),
        )
      ],
    );
  }

  Widget _profileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: SizeConfig.widthMultiplier * 65,
                child: TextFormField(
                  maxLines: 2,
                  minLines: 1,
                  focusNode: _focusNode,
                  enabled: isEnabled,
                  initialValue: userProvider.data.username,
                  decoration: InputDecoration.collapsed(hintText: ''),
                  style: TextStyle(
                      fontSize: SizeConfig.textMultiplier * 3,
                      color: ColorProvider.secondaryColor,
                      fontWeight: FontWeight.bold),
                  onSaved: (String value) {
                    _username = value;
                  },
                ),
              ),
              IconButton(
                onPressed: () => saveEditProfileUserButton(),
                icon: Icon(
                  _icon,
                  color: ColorProvider.primaryDark,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: SizeConfig.heightMultiplier * 1.6),
            child: Divider(thickness: 1),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: SizeConfig.heightMultiplier * 2, bottom: SizeConfig.heightMultiplier * 2),
                child: Text(
                  '${AppStrings.emailHint}: ',
                  style: TextStyle(
                      fontSize: SizeConfig.textMultiplier * 2,
                      color: ColorProvider.secondaryColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                enabled: isEnabled,
                decoration: InputDecoration.collapsed(hintText: '${userProvider.data.email}'),
                style: TextStyle(fontSize: SizeConfig.textMultiplier * 2),
                onSaved: (String value) {
                  _email = value;
                },
              ),
              SizedBox(
                height: SizeConfig.heightMultiplier,
              ),
              Divider(),
              Container(
                margin: EdgeInsets.only(top: SizeConfig.heightMultiplier * 2, bottom: SizeConfig.heightMultiplier * 2),
                child: Text(
                  '${AppStrings.passwordHint}: ',
                  style: TextStyle(
                      fontSize: SizeConfig.textMultiplier * 2,
                      color: ColorProvider.secondaryColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
              TextFormField(
                obscureText: true,
                maxLines: 1,
                enabled: isEnabled,
                decoration: InputDecoration.collapsed(hintText: '******'),
                style: TextStyle(fontSize: SizeConfig.textMultiplier * 2),
                onSaved: (String value) {
                  _password = value;
                },
              ),
              SizedBox(
                height: SizeConfig.heightMultiplier,
              ),
              Divider(),
            ],
          ),
        ],
      ),
    );
  }
}
