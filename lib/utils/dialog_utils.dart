import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_app/models/group.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/providers/group_provider.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';
import 'package:meeting_app/widget/input_dialog_text_widget.dart';
import 'package:provider/provider.dart';

//Class to generate the different dialog used in the app
class DialogUtils {
  //Dialog to create a custom simple dialog
  static Future showCustomDialog(
      {@required BuildContext context,
      @required Widget content,
      Widget title,
      List<FlatButton> actions,
      bool dismissOnBackPressed = true}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        child: AlertDialog(
          title: title,
          content: content,
          actions: actions,
        ),
        onWillPop: () async {
          if (dismissOnBackPressed) Navigator.pop(context);
          return false;
        },
      ),
    );
  }

  //Dialog to create a loading dialog action to wait a result
  static void showLoadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
        onWillPop: () async {
          return false;
        },
      ),
    );
  }

  //Dialog that is used when there is a problem in the application
  static void showAlertDialog(
      {@required BuildContext context,
      @required String title,
      @required String content,
      String dismissButtonText,
      bool dismissOnBackPressed = true}) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        child: AlertDialog(
          title: Text(
            title,
          ),
          content: Text(
            content,
          ),
          actions: [
            MaterialButton(
              child: Text(dismissButtonText != null ? dismissButtonText : AppStrings.closeButton),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        onWillPop: () async {
          if (dismissOnBackPressed) Navigator.pop(context);
          return false;
        },
      ),
    );
  }

  //SnackBar to show a message in the bottom of the app
  static void showMessageSnackBar(GlobalKey<ScaffoldState> key, String message) {
    key?.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  static Future showInviteCodeDialog(
      {@required BuildContext context, String code, bool dismissOnBackPressed = true}) async {
    final _formKey = GlobalKey<FormState>();
    String _code;
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => WillPopScope(
        child: Dialog(
          backgroundColor: ColorProvider.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
          ),
          //dialog height
          child: Container(
            height: SizeConfig.heightMultiplier * 60,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(16),
                  child: Text(
                    "Invitacion",
                    style: Styles.textFriends,
                  ),
                ),
                Expanded(
                  child: Container(
                    color: ColorProvider.white,
                    child: Container(
                      margin: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 2,
                          ),
                          Text(
                            "Codigo del grupo:",
                            style: Styles.textPrimaryColorMoreSize,
                          ),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 2,
                          ),
                          Form(
                              key: _formKey,
                              child: InputTextDialog(
                                  value: code != null ? code : '', onSaved: (String text) => _code = text)),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              FlatButton(
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(color: ColorProvider.blackOpacity, fontSize: 16),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  "Unirme",
                                  style: TextStyle(color: ColorProvider.primaryColor, fontSize: 16),
                                ),
                                onPressed: () async {
                                  _formKey.currentState.save();
                                  if (_code != null) {
                                    final response = await NetworkHelper().addMember(groupInvitedLink: _code);
                                    if (response != null) {
                                      final _scaffoldKey = Provider.of<GlobalKey<ScaffoldState>>(context);
                                      if (response.toString() == 'false') {
                                        Navigator.pop(context);
                                        showMessageSnackBar(_scaffoldKey, "Ya es miembro de este grupo");
                                      } else {
                                        GroupProvider _groupProvider = Provider.of<GroupProvider>(context);
                                        _groupProvider.addGroup(Group.fromJson(response));
                                        Navigator.pop(context);
                                      }
                                    }
                                  }
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (dismissOnBackPressed) Navigator.pop(context);
          return false;
        },
      ),
    );
  }

  //Dialog that show the create and modify a group info
  static Future showGroupDialog({
    @required BuildContext context,
    @required String title,
    @required String action,
    int groupIndex,
    String groupId,
    bool dismissOnBackPressed = true,
  }) {
    //to avoid errors in the actions
    action = action.toUpperCase();

    //crate provider to notify changes in the list of groups
    GroupProvider _groupProvider = Provider.of<GroupProvider>(context, listen: false);

    //key to save form
    final _formKey = GlobalKey<FormState>();
    final _scaffoldKey = Provider.of<GlobalKey<ScaffoldState>>(context, listen: false);

    //group data
    Group group;
    String _name;
    String _description;
    File _image;

    //loading result
    bool loading = false;

    //if the actions is modify get the group and fill the name and description
    if (action == "MODIFICAR") {
      group = _groupProvider.getGroup(groupId);
    }

    //ImagePicker
    void _getImage() async {
      _image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );
    }

    //verify the action to do on action button depending on action value
    void _checkActions(String value) async {
      //validate form
      final isValid = _formKey.currentState.validate();

      if (isValid) {
        //save the values of the form
        _formKey.currentState.save();

        //General variables of switch
        String message;
        NetworkHelper networkHelper = NetworkHelper();

        dynamic response;

        switch (value.toUpperCase()) {
          //Create case
          case "CREAR":
            loading = true;
            if (loading) {
              Navigator.pop(context);
              showLoadingDialog(context);
              response = await networkHelper.createGroup(context,
                  groupName: _name, descriptionGroup: _description, image: _image);

              if (response != null) {
                message = "El grupo se creo correctamente";
                Group group = Group.fromJson(response);
                _groupProvider.addGroup(group);
              } else {
                message = AppStrings.errorLabel;
              }
              loading = false;
            }
            Navigator.pop(context);
            showMessageSnackBar(_scaffoldKey, message);
            break;

          //Modify case
          case "MODIFICAR":
            loading = true;
            if (loading) {
              if (_name != '' && _name != null && _name.trim().length > 0) {
                Navigator.pop(context);
                showLoadingDialog(context);
                response = await networkHelper.updateGroup(context,
                    groupName: _name, descriptionGroup: _description, groupId: groupId, image: _image);

                if (response != null) {
                  message = "El grupo se actualiso correctamente";

                  group = Group.fromJson(response);
                  _groupProvider.editGroup(groupIndex, group);
                } else {
                  message = AppStrings.errorLabel;
                }
              } else {
                message = AppStrings.errorLabel;
              }
            }

            Navigator.pop(context);

            //Show snackBar with the result message
            showMessageSnackBar(_scaffoldKey, message);
            break;
        }
      }
    }

    //Show the group dialog
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: ColorProvider.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(40.0),
                ),
              ),
              //dialog height
              child: Container(
                height: SizeConfig.heightMultiplier * 60,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    //top message on dialog
                    Container(
                      alignment: Alignment.center,
                      height: SizeConfig.heightMultiplier * 12,
                      child: Text(
                        title,
                        style: Styles.textFriends,
                      ),
                    ),

                    //Form of the dialog
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40)), color: ColorProvider.white),
                      margin: EdgeInsets.only(top: SizeConfig.heightMultiplier * 18),
                      padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 8),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          margin: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Nombre del grupo:",
                                style: Styles.textPrimaryColorMoreSize,
                              ),
                              InputTextDialog(
                                value: group != null ? group.groupName : '',
                                validator: (String value) {
                                  _name = value;
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: SizeConfig.heightMultiplier * 6,
                              ),
                              Text(
                                "Descripcion del grupo:",
                                style: Styles.textPrimaryColorMoreSize,
                              ),
                              InputTextDialog(
                                value: group != null ? group.description : '',
                                onSaved: (String value) {
                                  _description = value;
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: SizeConfig.heightMultiplier * 3.5,
                              ),
                              //buttons of form
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      AppStrings.cancelButton,
                                      style: TextStyle(color: ColorProvider.blackOpacity),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      action,
                                      style: TextStyle(color: ColorProvider.secondaryColor),
                                    ),
                                    onPressed: () async {
                                      _checkActions(action);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    //image picker
                    GestureDetector(
                      onTap: () {
                        _getImage();
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: SizeConfig.heightMultiplier * 10),
                        height: SizeConfig.heightMultiplier * 15,
                        width: SizeConfig.heightMultiplier * 15,
                        decoration: BoxDecoration(
                          color: ColorProvider.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(SizeConfig.widthMultiplier * 20)),
                          border: Border.all(color: ColorProvider.white, width: 3),
                        ),
                        child: _image != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(_image),
                              )
                            : Container(
                                child: group?.imgUrl == null
                                    ? Icon(
                                        Icons.add_a_photo,
                                        color: ColorProvider.white,
                                        size: SizeConfig.heightMultiplier * 6,
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(group.imgUrl),
                                      ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        onWillPop: () async {
          if (dismissOnBackPressed) Navigator.pop(context);
          return false;
        },
      ),
    );
  }
}
