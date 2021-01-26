library backdrop;

import 'dart:async';

import 'package:flutter/material.dart';

//Modified implementation of [BackDrop]
//
//a modified class that reverse the layers of the [BackDrop] implementation
class Frontdrop extends InheritedWidget {
  final _FrontdropScaffoldState data;

  Frontdrop({Key key, @required this.data, @required Widget child}) : super(key: key, child: child);

  static _FrontdropScaffoldState of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(Frontdrop) as Frontdrop).data;

  @override
  bool updateShouldNotify(Frontdrop old) => true;
}

class FrontdropScaffold extends StatefulWidget {
  final AnimationController controller;
  final Widget title;
  final Widget backLayer;
  final Widget frontLayer;
  final double headerHeight;
  final BorderRadius frontLayerBorderRadius;
  final Color appbarColor;
  final Icon leadingIcon;
  final AnimatedIconData leadingAnimatedIconData;

  FrontdropScaffold({
    this.controller,
    this.title,
    this.backLayer,
    this.frontLayer,
    this.headerHeight = 32.0,
    this.appbarColor,
    this.leadingIcon,
    this.leadingAnimatedIconData,
    this.frontLayerBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(32.0),
      topRight: Radius.circular(32.0),
    ),
  });

  @override
  _FrontdropScaffoldState createState() => _FrontdropScaffoldState();
}

class _FrontdropScaffoldState extends State<FrontdropScaffold> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool shouldDisposeController = false;
  AnimationController _controller;

  AnimationController get controller => _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      shouldDisposeController = true;
      _controller = AnimationController(duration: Duration(milliseconds: 100), value: 1.0, vsync: this);
    } else {
      _controller = widget.controller;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (shouldDisposeController) {
      _controller.dispose();
    }
  }

  bool get isTopPanelVisible {
    final AnimationStatus status = controller.status;
    return status == AnimationStatus.completed || status == AnimationStatus.forward;
  }

  bool get isFrontPanelVisible {
    final AnimationStatus status = controller.status;
    return status == AnimationStatus.dismissed || status == AnimationStatus.reverse;
  }

  void fling() {
    controller.fling(velocity: isTopPanelVisible ? -1.0 : 1.0);
    setState(() {});
  }

  void showBackLayer() {
    if (isTopPanelVisible) {
      controller.fling(velocity: -1.0);
    }
  }

  void showFrontLayer() {
    if (!isFrontPanelVisible) {
      controller.fling(velocity: 1.0);
    }
  }

  Animation<RelativeRect> getPanelAnimation(BuildContext context, BoxConstraints boxConstraints) {
    final height = boxConstraints.biggest.height;
    final backPanelHeight = height - widget.headerHeight;
    final frontPanelHeight = -backPanelHeight;

    return RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, backPanelHeight, 0.0, frontPanelHeight),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));
  }

  Widget _buildBackPanel(BuildContext context) {
    return widget.backLayer;
  }

  Widget _buildFrontPanel() {
    return Material(
      elevation: 20.0,
      borderRadius: widget.frontLayerBorderRadius,
      child: widget.frontLayer,
    );
  }

  Future<bool> _willPopCallback(BuildContext context) async {
    if (isFrontPanelVisible) {
      fling();
      return null;
    }
    return true;
  }

  Widget _buildBody(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPopCallback(context),
      child: Scaffold(
        key: scaffoldKey,
        appBar: isFrontPanelVisible
            ? AppBar(
                title: widget.title,
                elevation: 0,
                leading: BackdropToggleButton(),
              )
            : null,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Theme.of(context).primaryColor,
              child: Stack(
                children: <Widget>[
                  _buildFrontPanel(),
                  PositionedTransition(
                    rect: getPanelAnimation(context, constraints),
                    child: _buildBackPanel(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Frontdrop(
      data: this,
      child: Builder(
        builder: (context) => _buildBody(context),
      ),
    );
  }
}

class BackdropToggleButton extends StatelessWidget {
  final AnimatedIconData icon;

  const BackdropToggleButton({
    this.icon = AnimatedIcons.close_menu,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: icon,
        progress: Frontdrop.of(context).controller.view,
      ),
      onPressed: () => Frontdrop.of(context).fling(),
    );
  }
}

class BackdropFloatingButton extends StatelessWidget {
  final Icon icon;

  const BackdropFloatingButton({Key key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FloatingActionButton.extended(
        icon: icon,
        label: Text('Chat'),
        onPressed: () => Frontdrop.of(context).fling(),
      ),
    );
  }
}
