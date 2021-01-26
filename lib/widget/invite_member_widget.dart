import 'package:flutter/material.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/pages/join_group_page.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/widget/input_form_text_widget.dart';

class AddCodeWidget extends StatefulWidget {
  final String inviteCode;

  const AddCodeWidget({Key key, this.inviteCode = ''}) : super(key: key);

  @override
  _AddCodeWidgetState createState() => _AddCodeWidgetState();
}

class _AddCodeWidgetState extends State<AddCodeWidget> {
  //a Key for the [Form]
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //variable to manipule the [widget.inviteCode]
  String invitedLink = '';

  //variable to validate the [inputForm]
  bool incorrectCode = false;

  //on init
  @override
  void initState() {
    //get the [inviteCode] if exist and modify [invitedLink]
    getInvitedLink();
    super.initState();
  }

  //build
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Container(
            height: SizeConfig.heightMultiplier * 10,
            child: InputTextForm(
              value: invitedLink,
              label: AppStrings.groupInviteCode,
              validator: (String text) {
                if (text.isEmpty || incorrectCode) {
                  return AppStrings.errorCodeInvalid;
                }
                invitedLink = text;
                return null;
              },
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.heightMultiplier * 5,
        ),
        Container(
          height: SizeConfig.heightMultiplier * 7,
          child: MaterialButton(
              color: ColorProvider.primaryColor,
              child: Text(
                AppStrings.joinMeButton,
                style: TextStyle(color: ColorProvider.white, fontSize: SizeConfig.textMultiplier * 3),
              ),
              shape: StadiumBorder(),
              onPressed: () => verifyInvitedLink()),
        ),
      ],
    );
  }

  //action to do when [widget.inviteCode] is different to null
  void getInvitedLink() {
    if (widget.inviteCode != null && widget.inviteCode != '') {
      //split the [widget.inviteCode]
      final split = widget?.inviteCode?.split('=');
      //assign the split part of code in to a [invitedLink]
      invitedLink = split[0];
    }
  }

  //verify if the [invitedLink] exist
  void verifyInvitedLink() async {
    //trim the link to avoid errors
    invitedLink = invitedLink.trim();
    //validate the form and save the value to [invitedLink]
    _formKey.currentState.validate();
    //check the value of the [invitedLink]
    if (invitedLink != '') {
      //send request and await a response
      final response = await NetworkHelper().verifyCode(invitedLink);

      //check if the response exist
      if (response == null) {
        //on null response
        //change the value of [incorrectCode]
        incorrectCode = true;
        //validate the form again to show the error message
        _formKey.currentState.validate();
        return;
      }

      //if all ok navigate to [JoinGroupPage] with the [group.Id]
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinGroupPage(
            groupId: response['id'],
          ),
        ),
      );
      incorrectCode = false;
      return;
    }
  }
}
