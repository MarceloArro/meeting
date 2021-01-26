import 'package:flutter/material.dart';
import 'package:meeting_app/models/group.dart';
import 'package:meeting_app/providers/group_provider.dart';
import 'package:meeting_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'group_list_item_widget.dart';

class GroupList extends StatelessWidget {
  final List<Group> groups;

  const GroupList({Key key, this.groups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider = Provider.of<UserProvider>(context);
    GroupProvider _groupProvider = Provider.of<GroupProvider>(context);

    bool isOwner;

    //build list with group_list_items
    return Container(
      //is one item of the list change, rebuild the List
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          //obtain the group from list[Index]
          final group = groups[index];
          //obtain if the user is the owner of the group or not
          _userProvider.data.uid == group.owner ? isOwner = true : isOwner = false;
          //return a groupItem for the group
          return GroupListItem(group: group, isOwner: isOwner, index: index, groupProvider: _groupProvider);
        },
      ),
    );
  }
}
