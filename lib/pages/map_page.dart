import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:meeting_app/models/message.dart';
import 'package:meeting_app/models/point.dart';
import 'package:meeting_app/networks/helper_network.dart';
import 'package:meeting_app/providers/chat_provider.dart';
import 'package:meeting_app/providers/point_provider.dart';
import 'package:meeting_app/providers/user_provider.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/socket_client.dart';
import 'package:meeting_app/utils/string_utils.dart';
import 'package:meeting_app/widget/chat_item_widget.dart';
import 'package:meeting_app/widget/frontdrop_widget.dart';
import 'package:meeting_app/widget/marker_point_widget.dart';
import 'package:provider/provider.dart';

//Page that contains the map and chat
class MapPage extends StatefulWidget {
  //value for the socket room
  final String groupId;

  //value to check if the user is a invited or not
  final bool invited;

  const MapPage({Key key, this.groupId, this.invited = false}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //Initial point in map
  LatLng _center = LatLng(0.0, -50.0);

  //The actual values of locationServices
  LocationData _currentLocation;

  //Stream of location
  StreamSubscription<LocationData> _locationSubscription;

  //create the location services
  Location _locationService = new Location();

  //create controller of map
  MapController _mapController = MapController();

  //create controller for text
  final textController = TextEditingController();

  //create controller for scroll in listView (ChatLayer)
  final scrollController = ScrollController();

  //Create socketClient
  final _socketClient = SocketClient();

  //value [Point] to compare and filter points
  Points oldPoint;

  //value of error message
  String error;

  //providers
  ChatProvider _chatProvider;
  UserProvider _userProvider;
  PointsProvider _pointsProvider;

  //initState
  @override
  void initState() {
    //init locationServices
    _initPlatformState();

    //init socketIO
    _connectSocket();

    super.initState();
  }

  //Dispose
  @override
  void dispose() {
    //check socketClient and disconnect
    _socketClient?.disconnect();

    //check locationStream and disconnect
    _locationSubscription?.cancel();

    //Dispose controllers
    textController?.dispose();
    scrollController?.dispose();
    super.dispose();
  }

  //Connect Socket and init the functions
  void _connectSocket() async {
    //connection

    //crete [token] value
    String token;

    //check if the user is logged or not and get the [token]
    if (!widget.invited) {
      token = await NetworkHelper().getAccessToken();
    }

    //connect to the socket in the [groupId] and manage the token
    await _socketClient.connect(widget.groupId, token);

    //onNewMessage event
    _socketClient.onNewMessage = (data) {
      //get the data from the socket and transform in a [message]
      final message = Message.fromJson(data['message'])..myMessage = false;
      //add the message to the [ChatProvider]
      _chatProvider.addMessage(message);
    };

    //onNewLocation event
    _socketClient.onNewLocation = (data) {
      //create [Point] with the obtained data from socketIO
      Points point = Points(
        latitude: data['location']['latitude'],
        longitude: data['location']['longitude'],
        userId: data['from']['id'],
        userName: data['from']['username'],
        marker: Marker(
          point: LatLng(
            data['location']['latitude'],
            data['location']['longitude'],
          ),
          width: 30.0,
          height: 60.0,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (_) => MarkerItems(
            name: data['from']['username'],
          ),
        ),
      );

      //get a point if have the same [userId] in the provider list  [ListPoint]
      Points refPoint = _pointsProvider.filterPointAndGetPoint(point.userId);

      //check if the referential [Point] exist or not
      if (refPoint != null) {
        //if the point exist remove the oldPoint
        _pointsProvider.removePoint(_pointsProvider.getPointIndex(refPoint));
      }
      //add the new point location
      _pointsProvider.addPoint(point);
    };

    //onConnected event
    _socketClient.onConnected = (data) {
      //final users = Map<String, dynamic>.from(data['connectedUsers']);
      //get the [userId] from the backend and add the new value on [UserProvider]
      _userProvider.data.uid = data['userId'];
    };

    //onJoined event
    _socketClient.onJoined = (data) {
//      print("joined: ${data.toString()}");
    };

    //onDisconnect event
    _socketClient.onDisconnected = (data) {
      //remove the point of the user that disconnected
      _pointsProvider.removePoint(
        _pointsProvider.getPointIndex(
          _pointsProvider.filterPointAndGetPoint(data),
        ),
      );
    };
  }

  //Manage the emit [message] event in socketIO
  void _sendMessage(String text) {
    //create a new [message]
    Message message = Message(
      userName: _userProvider.data.username,
      avatar: _userProvider.data.avatar,
      text: text,
      type: 'text',
      myMessage: true,
    );

    //check the value of the [message.text]
    if (text != '') {
      //Convert the [message] in JSON and send the message to the socketIO
      _socketClient.emit('send', message.toJson());
      //add the [message] to the [ChatProvider]
      _chatProvider.addMessage(message);
      //Clear the text in the input
      textController.clear();
      //scroll the chat to the bottom
      goToEnd();
    }
  }

  //Manage the emit [sendLocation] event in SocketIO
  void _sendLocation(LocationData location) {
    //Check if exist and older [Point] location
    if (oldPoint != null) {
      //remove the older point
      debugPrint(_pointsProvider.getPointIndex(oldPoint).toString());
      _pointsProvider.removePoint(
        _pointsProvider.getPointIndex(oldPoint),
      );
    }

    //create a new [Point] with the [location]
    Points newPoint = Points(
      latitude: location.latitude,
      longitude: location.longitude,
      userName: _userProvider.data.username,
      userId: _userProvider.data.uid,
      marker: Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 28.0,
        height: 50.0,
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (_) => MarkerItems(),
      ),
    );

    //replace the [oldPoint] value with the [newPoint] value
    oldPoint = newPoint;

    //add the [Point] to the [PointProvider]
    _pointsProvider.addPoint(newPoint);

    //Emit the [sendLocation] event and convert the [Point] in JSON
    _socketClient.emit('sendLocation', newPoint.toJson());
  }

  //Init the [LocationServices] to get the location values
  void _initPlatformState() async {
    //Changes the defaults settings of [LocationServices]
    await _locationService.changeSettings(accuracy: LocationAccuracy.high, interval: 500);

    // Platform messages may fail, so use a try/catch PlatformException.
    try {
      //Obtain the value of [ServicesStatus] reference if [GPS] is enabled or nor
      bool serviceStatus = await _locationService.serviceEnabled();

      //check the value of the gps
      if (serviceStatus) {
        //obtain if user permit the manage of gps
        PermissionStatus _permission = await _locationService.requestPermission();

        //check the [_Permission] value
        if (_permission == PermissionStatus.granted || _permission == PermissionStatus.grantedLimited) {
          //if all ok clear the providers data
          _chatProvider.clearMessages();
          _pointsProvider.clearPoint();

          //make a Subscription of [locationServices]
          _locationSubscription = _locationService.onLocationChanged.listen(
            (LocationData result) async {
              //check the value of [oldPoint] and on first [Point] move the map on te location
              if (oldPoint == null) {
                _mapController.move(LatLng(result.latitude, result.longitude), 16);
              }

              if (mounted) {
                setState(
                  () {
                    //Obtain the new [LocationData]
                    _currentLocation = result;
                    //send the new [LocationData] to [_sendLocation]
                    _sendLocation(_currentLocation);
                  },
                );
              }
            },
          );
        }
        //if the gps is not enable request the permission services
      } else {
        //request geolocation services
        bool serviceStatusResult = await _locationService.requestService();
        //check if gps is enabled
        if (serviceStatusResult) {
          //init the [PlatformState] again
          _initPlatformState();
        }
      }
      //catch the errors
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      _locationSubscription = null;
    }
  }

  //build method
  @override
  Widget build(BuildContext context) {
    //providers
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _pointsProvider = PointsProvider.of(context);
    _chatProvider = ChatProvider.of(context);

    //use the FrontDropScaffold
    return FrontdropScaffold(
      backLayer: mapWidget(),
      frontLayer: chatWidget(),
      headerHeight: 0,
      title: Text('Chat'),
    );
  }

  //Map Widget
  Widget mapWidget() {
    return Stack(
      children: <Widget>[
        FlutterMap(
          options: MapOptions(
            center: _center,
            zoom: 16.0,
            minZoom: 4.0,
            maxZoom: 22.0,
          ),
          mapController: _mapController,
          layers: [
            TileLayerOptions(
              urlTemplate: "https://api.mapbox.com/v4/"
                  "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
              additionalOptions: {
                'accessToken':
                    'pk.eyJ1IjoibWFyY2Vsb2Fycm8iLCJhIjoiY2puemQwb2tiMDB0NjNrbzQ1d3lxZ3phaiJ9.YfYJ67TBfueonbz9cB62vw',
                'id': 'mapbox.mapbox-terrain-v2',
              },
            ),
            MarkerLayerOptions(
              markers: _pointsProvider.markerList,
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FloatingActionButton(
                tooltip: AppStrings.miLocation,
                child: Icon(Icons.my_location),
                onPressed: _moveAnimated,
                heroTag: null,
              ),
              SizedBox(
                height: 16,
              ),
              BackdropFloatingButton(
                icon: Icon(Icons.chat),
              ),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 64, left: 16),
            alignment: Alignment.topLeft,
            child: FloatingActionButton(
              heroTag: '',
              child: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )),
      ],
    );
  }

  //chat Widget
  Widget chatWidget() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: _chatProvider.messages.length,
            itemBuilder: (context, index) {
              final message = _chatProvider.messages[index];
              return messageListItem(message);
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: CupertinoTextField(
                  controller: textController,
                  style: TextStyle(color: ColorProvider.white),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorProvider.secondaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(width: 10),
              CupertinoButton(
                onPressed: () => _sendMessage(textController.value.text),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                borderRadius: BorderRadius.circular(20),
                minSize: 30,
                color: ColorProvider.secondaryDark,
                child: Text(AppStrings.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //center map to location
  void _moveAnimated() async {
    _mapController.move(LatLng(_currentLocation.latitude, _currentLocation.longitude), 14);
  }

  //scroll to end in [Chat Widget]
  void goToEnd() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.linear);
  }
}
