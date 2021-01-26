import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/models/message.dart';
import 'package:meeting_app/networks/constants_network.dart';
import 'package:meeting_app/utils/colors_utils.dart';

// item widget for [MessageList]
Widget messageListItem(Message message) {
  return Container(
    margin: EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // verify if the user send the message or not
        //if not the [CirCleAvatar] go to the start of screen
        !message.myMessage
            ? CircleAvatar(
                backgroundImage:
                    message.avatar != null ? NetworkImage("${NetworkConstants.HOST}${message.avatar}") : null)
            : Container(),
        //Wrap message to extend the bubble of the text
        Wrap(
          children: <Widget>[
            //Message bubble
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 330, maxWidth: 330),
              child: Container(
                margin: message.myMessage ? EdgeInsets.only(right: 6) : EdgeInsets.only(left: 6),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: message.myMessage ? ColorProvider.secondaryLight : ColorProvider.primaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      message.text,
                      style: TextStyle(color: ColorProvider.white, fontWeight: FontWeight.w300),
                    ),
                    Padding(
                      child: Text(
                        !message.myMessage ? message.userName : 'Yo',
                        style: TextStyle(fontSize: 12, color: ColorProvider.white),
                      ),
                      padding: EdgeInsets.only(bottom: 10, top: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // verify if the user send the message or not
        //if not the [CirCleAvatar] go to the end of screen
        message.myMessage
            ? CircleAvatar(
                backgroundImage:
                    message.avatar != null ? NetworkImage("${NetworkConstants.HOST}${message.avatar}") : null)
            : Container(),
      ],
    ),
  );
}
