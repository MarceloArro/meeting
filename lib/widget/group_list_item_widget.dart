import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/models/group.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/pages/map_page.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/dialog_utils.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class GroupListItem extends StatelessWidget {
  final Group group;
  final bool isOwner;
  final int index;
  final groupProvider;

  const GroupListItem({Key key, this.group, this.isOwner, this.index, this.groupProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //loading
    bool loading = false;

    //PopupMenus declarations
    PopupMenuButton notOwnerPopupMenuButton;
    PopupMenuButton isOwnerPopupMenuButton;

    //generate sharedLink
    void _generateLink() async {
      var response;

      if (loading) {
        DialogUtils.showLoadingDialog(context);
        response = await NetworkHelper().getShareLink(groupId: group.id);
        loading = false;
        Navigator.pop(context);
      }
      if (response != null) {
        Share.share(response.toString(), subject: "Unete al grupo");
      }
    }

    //delete group
    void _deleteGroup() async {
      DialogUtils.showCustomDialog(
        context: context,
        content: Text(AppStrings.areYouSureDelete),
        title: Text(AppStrings.delete),
        actions: [
          FlatButton(
            child: Text(
              AppStrings.cancelButton,
              style: TextStyle(color: ColorProvider.blackOpacity),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text(
              AppStrings.acceptButton,
              style: TextStyle(color: ColorProvider.red),
            ),
            onPressed: () async {
              String message;
              var response = await NetworkHelper().deleteGroup(groupId: group.id);
              Navigator.pop(context);
              if (response) {
                message = AppStrings.deleteSuccessfully;
                groupProvider.removeGroup(index);
              } else {
                message = AppStrings.errorLabel;
              }
              DialogUtils.showMessageSnackBar(Provider.of<GlobalKey<ScaffoldState>>(context, listen: false), message);
            },
          ),
        ],
      );
    }

    //Modify Action
    void _updateGroup() {
      DialogUtils.showGroupDialog(
          context: context,
          title: AppStrings.modifyGroup,
          action: AppStrings.modify,
          groupId: group.id,
          groupIndex: index);
    }

    //exitGroup Action
    void _exitGroup() async {
      final response = await NetworkHelper().deleteMember(groupId: group.id);
      if (response.toString() == 'true') {
        groupProvider.removeGroup(index);
        return;
      }
    }

    //check selected option in PopupMenu
    Future _checkValue(String value) async {
      //evaluate expression
      switch (value.toLowerCase()) {
        case 'share':
          loading = true;
          _generateLink();
          break;

        case 'update':
          _updateGroup();
          break;
        case 'delete':
          _deleteGroup();
          break;

        case 'exit':
          _exitGroup();
          break;
      }
    }

    //common PopupItem
    PopupMenuItem share = PopupMenuItem(
      child: Text("Invitar"),
      value: "share",
    );

    //Popup for not owners
    notOwnerPopupMenuButton = PopupMenuButton(
      itemBuilder: (_) => [
        share,
        PopupMenuItem(
          child: Text("Salir"),
          value: "exit",
        ),
      ],
      tooltip: AppStrings.options,
      onSelected: (value) {
        _checkValue(value);
      },
    );

    //Popup for owners
    isOwnerPopupMenuButton = PopupMenuButton(
      itemBuilder: (_) => [
        share,
        PopupMenuItem(
          child: Text(AppStrings.modify),
          value: "update",
        ),
        PopupMenuItem(
          child: Text(AppStrings.delete),
          value: "delete",
        ),
      ],
      tooltip: AppStrings.options,
      onSelected: (value) {
        _checkValue(value);
      },
    );

    //item for [groupList]
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(group.groupName),
            subtitle: group.description != '' ? Text(group.description) : null,
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: ColorProvider.secondaryColor,
              backgroundImage: group.imgUrl != null ? NetworkImage(group.imgUrl) : null,
              child: group.imgUrl != null
                  ? null
                  : Text(
                      group.groupName[0].toUpperCase(),
                      style: Styles.textColorWhite,
                    ),
            ),
            trailing: isOwner ? isOwnerPopupMenuButton : notOwnerPopupMenuButton,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapPage(
                    groupId: group.id,
                  ),
                ),
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
