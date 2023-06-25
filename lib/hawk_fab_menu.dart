library hawk_fab_menu;

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Used to toggle the menu from other than the dedicated button.
class HawkFabMenuController {
  late Function toggleMenu;
  HawkFabMenuController();
}

/// Wrapper that builds a FAB menu on top of [body] in a [Stack]
class HawkFabMenu extends StatefulWidget {
  final Widget body;
  final List<HawkFabMenuItem> items;
  final double blur;
  final AnimatedIconData? icon;
  final Text? openText;
  final Text? closeText;
  final int? animationDuration;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? openContainerColor;
  final Color? closeContainerColor;
  final IconData? openIcon;
  final IconData? closeIcon;
  final Color? fabColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final BorderSide buttonBorder;
  final String? heroTag;
  final HawkFabMenuController? hawkFabMenuController;

  HawkFabMenu({
    Key? key,
    required this.body,
    required this.items,
    this.openText,
    this.closeText,
    this.blur = 5.0,
    this.icon,
    this.fabColor,
    this.iconColor,
    this.backgroundColor,
    this.buttonBorder = BorderSide.none,
    this.openIcon,
    this.closeIcon,
    this.heroTag,
    this.hawkFabMenuController,  this.animationDuration, this.margin, this.padding, this.openContainerColor, this.closeContainerColor,
  }) : super(key: key) {
    assert(items.isNotEmpty);
  }

  @override
  _HawkFabMenuState createState() => _HawkFabMenuState();
}

class _HawkFabMenuState extends State<HawkFabMenu>
    with TickerProviderStateMixin {
  /// To check if the menu is open
  bool _isOpen = false;

  /// The [Duration] for every animation
  final Duration _duration = const Duration(milliseconds: 500);

  /// Animation controller that animates the menu item
  late AnimationController _iconAnimationCtrl;

  /// Animation that animates the menu item
  late Animation<double> _iconAnimationTween;

  @override
  void initState() {
    super.initState();
    _iconAnimationCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _iconAnimationTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_iconAnimationCtrl);

    if (widget.hawkFabMenuController != null) {
      widget.hawkFabMenuController!.toggleMenu = _toggleMenu;
    }
  }

  @override
  void dispose() {
    _iconAnimationCtrl.dispose();
    super.dispose();
  }

  /// Closes the menu if open and vice versa
  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _iconAnimationCtrl.forward();
    } else {
      _iconAnimationCtrl.reverse();
    }
  }

  /// If the menu is open and the device's back button is pressed then menu gets closed instead of going back.
  Future<bool> _preventPopIfOpen() async {
    if (_isOpen) {
      _toggleMenu();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          widget.body,
          _isOpen ? _buildBlurWidget() : Container(),
          _isOpen ? _buildMenuItemList() : Container(),
          _buildMenuButton(context),
        ],
      ),
      onWillPop: _preventPopIfOpen,
    );
  }

  /// Returns animated list of menu items
  Widget _buildMenuItemList() {
    return Positioned(
      bottom: 80,
      right: 15,
      child: ScaleTransition(
        scale: AnimationController(
          vsync: this,
          value: 0.7,
          duration: _duration,
        )..forward(),
        child: SizeTransition(
          axis: Axis.horizontal,
          sizeFactor: AnimationController(
            vsync: this,
            value: 0.5,
            duration: _duration,
          )..forward(),
          child: FadeTransition(
            opacity: AnimationController(
              vsync: this,
              value: 0.0,
              duration: _duration,
            )..forward(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items
                  .map<Widget>(
                    (item) => _MenuItemWidget(
                      item: item,
                      toggleMenu: _toggleMenu,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the blur effect when the menu is opened
  Widget _buildBlurWidget() {
    return InkWell(
      onTap: _toggleMenu,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
        ),
        child: Container(
          color: widget.backgroundColor ?? Colors.black12,
        ),
      ),
    );
  }

  /// Builds the main floating action button of the menu to the bottom right
  /// On clicking of which the menu toggles
  Widget _buildMenuButton(BuildContext context) {
    late Widget iconWidget;
    if (widget.openIcon != null && widget.closeIcon != null) {
      iconWidget = Icon(
        _isOpen ? widget.closeIcon : widget.openIcon,
        color: widget.iconColor,
      );
    } else {
      iconWidget = AnimatedIcon(
        icon: widget.icon ?? AnimatedIcons.menu_close,
        progress: _iconAnimationTween,
        color: widget.iconColor,
      );
    }
    return Positioned(
      bottom: 10,
      right: 10,
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: _toggleMenu,
        child: AnimatedContainer(duration: Duration(milliseconds:widget.animationDuration?? 400),
        padding: widget.padding,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: _isOpen?widget.openContainerColor??Colors.green:widget.closeContainerColor??Colors.red,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.buttonBorder.color,width: widget.buttonBorder.width)
        ),
        child: Row(
          children: [
            iconWidget,
           const SizedBox(width: 20,),
           _isOpen? widget.openText??const SizedBox():widget.closeText??const SizedBox()
          ],
        ),
        ),
      ),
    );
  }
}

/// Builds widget for a single menu item
class _MenuItemWidget extends StatelessWidget {
  /// Contains details for a single menu item
  final HawkFabMenuItem item;

  /// A callback that toggles the menu
  final Function toggleMenu;

  const _MenuItemWidget({
    required this.item,
    required this.toggleMenu,
  });

  /// Closes the menu and calls the function for a particular menu item
  void onTap() {
    toggleMenu();
    item.ontap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: item.labelBackgroundColor ?? Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Text(
              item.label,
              style: TextStyle(color: item.labelColor ?? Colors.black87),
            ),
          ),
          FloatingActionButton(
            onPressed: onTap,
            heroTag: item.heroTag ?? '_MenuItemWidget_$hashCode',
            mini: true,
            shape: StadiumBorder(side: item.buttonBorder),
            child: item.icon,
            backgroundColor: item.color ?? Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

/// Model for single menu item
class HawkFabMenuItem {
  /// Text label for for the menu item
  String label;

  /// Corresponding icon for the menu item
  Icon icon;

  /// Action that is to be performed on tapping the menu item
  Function ontap;

  /// Background color for icon
  Color? color;

  // Border for the floatActionButton
  BorderSide buttonBorder;

  /// Text color for label
  Color? labelColor;

  /// Background color for label
  Color? labelBackgroundColor;

  /// The tag to apply to the button's [Hero] widget.
  String? heroTag;

  HawkFabMenuItem({
    required this.label,
    required this.ontap,
    required this.icon,
    this.color,
    this.buttonBorder = BorderSide.none,
    this.labelBackgroundColor,
    this.labelColor,
    this.heroTag,
  });
}
