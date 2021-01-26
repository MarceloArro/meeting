import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/models/group.dart';
import 'package:meeting_app/networks/constants_network.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/pages/profile_page.dart';
import 'package:meeting_app/providers/group_provider.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/dialog_utils.dart';
import 'package:meeting_app/utils/responsive_utils.dart';
import 'package:meeting_app/utils/session_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/widget/group_list_widget.dart';
import 'package:provider/provider.dart';

//Class that contain the [Group] list
class HomePage extends StatefulWidget {
  final String dynamicLink;

  const HomePage({Key key, this.dynamicLink = ''}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Key
  GlobalKey<ScaffoldState> _scaffoldKey;

  //variables
  String groupName;
  String groupDescription;
  bool _isFetching = true;

  //Providers
  GroupProvider _groupProvider;

  @override
  void initState() {
    //check the value of dynamicLin
    if (widget.dynamicLink != '') {
      //obtain the [invitedLink] of [dynamicLink]
      final split = widget.dynamicLink.split('=');
      final invitedLink = split[1];
      //show the dialog with the code
      DialogUtils.showInviteCodeDialog(context: context, code: invitedLink);
    }

    //init the groupProvider
    _groupProvider = Provider.of<GroupProvider>(context, listen: false);

    //get the [Group] list
    _getGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //obtain the _scaffoldKey created in the provider to manage SnackBar messages
    _scaffoldKey =
        Provider.of<GlobalKey<ScaffoldState>>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorProvider.primaryColor,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _createGroups(),
      ),
      appBar: _appBar(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorProvider.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(
                  40,
                ),
                topLeft: Radius.circular(
                  40,
                ),
              ),
            ),
          ),
          GroupList(
            groups: _groupProvider.groups,
          ),
          _isFetching
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  //Widget for [AppBar]
  Widget _appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(15 * SizeConfig.heightMultiplier),
      child: SafeArea(
        child: Container(
          height: 10 * SizeConfig.heightMultiplier,
          margin: EdgeInsets.only(left: 32, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppStrings.groups,
                style: TextStyle(
                    color: ColorProvider.white,
                    fontSize: SizeConfig.textMultiplier * 3),
              ),
              _popupMenu(),
            ],
          ),
        ),
      ),
    );
  }

  //widget for [PopUpMenu]
  Widget _popupMenu() {
//    [PopUpMenu] button
    return PopupMenuButton(
      tooltip: AppStrings.menuToolTip,
      icon: Icon(
        Icons.settings,
        color: ColorProvider.white,
        size: SizeConfig.textMultiplier * 3.5,
      ),
      onSelected: (String value) {
        switch (value) {
          case AppStrings.profileToolTip:
            _onProfile();
            break;
          case AppStrings.logoutToolTip:
            _onLogout();
            break;
          case "groupcode":
            _onGroupCode();
        }
      },
      //[PopUpMenu] Items
       itemBuilder: (context) => [
        PopupMenuItem(
          value: AppStrings.profileToolTip,
          child: Text(AppStrings.profileToolTip),
        ),
        PopupMenuItem(
          value: "groupcode",
          child: Text(AppStrings.groupCode),
        ),
        PopupMenuItem(
          value: AppStrings.logoutToolTip,
          child: Text(AppStrings.logoutToolTip),
        ),
      ],
    );
  }

  //get the list of [Groups] in the [user.groups]
  void _getGroups() async {
    //check the value of [_isFetching]
    if (_isFetching) {
      //get all the [Groups] info
      final result = await NetworkHelper().getGroupInfo();
      debugPrint("AQUI");
      //check the if exist a response
      if (result != null) {
        //clear the [GroupProvider]
        _groupProvider.clearGroups();
        //transform all the result element in a [Group]
        await result.forEach(
          (group) {
            //check if the element have an avatar
            if (group['imgUrl'] != null) {
              //if the avatar exist transform the url
              group['imgUrl'] = "${NetworkConstants.HOST}${group['imgUrl']}";
            }
            //add the [Group] element in the [GroupProvider]
            _groupProvider.addGroup(Group.fromJson(group));
          },
        );
        //change the state of the screen
        //to change the [CircleProgessBar]
        if (this.mounted) {
          setState(() {
            _isFetching = false;
          });
        }
      }
    }
  }

  //Floating action button action
  //Open the [groupDialog]
  void _createGroups() async {
    DialogUtils.showGroupDialog(
      context: context,
      title: AppStrings.createGroup,
      action: AppStrings.createButton,
    );
  }

  //PopUp actions
  //logOut action
  void _onLogout() {
    //show a [CustomDialog]
    DialogUtils.showCustomDialog(
      context: context,
      title: Text(
        AppStrings.logoutToolTip,
      ),
      content: Text(AppStrings.areYouSureLogOut),
      actions: [
        //button to cancel the action and back
        FlatButton(
          child: Text(
            AppStrings.cancelButton,
            style: TextStyle(color: ColorProvider.red),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        //button to manage the logOut action
        FlatButton(
          child: Text(
            AppStrings.acceptButton,
            style: TextStyle(color: ColorProvider.primaryColor),
          ),
          onPressed: () async {
            Navigator.pop(context);
            Session session = Session();
            //clear the token of [session] storage
            await session.clear();
            Navigator.pushNamedAndRemoveUntil(context, 'main', (_) => false);
          },
        ),
      ],
    );
  }

  //profile action
  void _onProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  //inv. code Action
  void _onGroupCode() {
    DialogUtils.showInviteCodeDialog(
      context: context,
    );
  }
}
