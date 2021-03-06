import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [MyExpansionTile] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.
class MyExpansionTile extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const MyExpansionTile({
    Key key,
    this.leading,
    @required this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.duration = _kExpand,
    this.expansionPadding = const EdgeInsets.symmetric(
      horizontal: 4.0,
    ),
    this.titlePadding =
        const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
    this.topBorder = false,
    this.bottomBorder = false,
    this.borderColor,
    this.titleColor,
    this.initiallyExpanded = false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color backgroundColor;

  /// A widget to display instead of a rotating arrow icon.
  final Widget trailing;

  final Duration duration;

  final EdgeInsets expansionPadding;

  final EdgeInsets titlePadding;

  final bool topBorder;

  final bool bottomBorder;

  final Color borderColor;

  final Color titleColor;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  @override
  _MyExpansionTileState createState() => new _MyExpansionTileState();
}

class _MyExpansionTileState extends State<MyExpansionTile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _easeOutAnimation;
  CurvedAnimation _easeInAnimation;
  ColorTween _borderColor;
  ColorTween _headerColor;
  ColorTween _iconColor;
  ColorTween _backgroundColor;
  Animation<double> _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        new AnimationController(duration: widget.duration, vsync: this);
    _easeOutAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _easeInAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _borderColor = new ColorTween();
    _headerColor = new ColorTween();
    _iconColor = new ColorTween();
    _iconTurns =
        new Tween<double>(begin: 0.0, end: 0.5).animate(_easeInAnimation);
    _backgroundColor = new ColorTween();

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded)
        _controller.forward();
      else
        _controller.reverse().then<void>((Null value) {
          setState(() {
            // Rebuild without widget.children.
          });
        });
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    final Color borderSideColor =
        _borderColor.evaluate(_easeOutAnimation) ?? Colors.transparent;
    final Color titleColor = _headerColor.evaluate(_easeInAnimation);

    return new Container(
      decoration: new BoxDecoration(
          color: _backgroundColor.evaluate(_easeOutAnimation) ??
              Colors.transparent,
          border: new Border(
            top: widget.topBorder
                ? new BorderSide(color: borderSideColor)
                : new BorderSide(color: Colors.transparent),
          )),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme.merge(
            data:
                new IconThemeData(color: _iconColor.evaluate(_easeInAnimation)),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: widget.bottomBorder
                      ? new BorderSide(color: borderSideColor)
                      : new BorderSide(color: Colors.transparent),
                ),
              ),
              child: new ListTile(
                dense: true,
                contentPadding: widget.titlePadding,
                onTap: _handleTap,
                leading: widget.leading,
                title: new DefaultTextStyle(
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: titleColor),
                  child: widget.title,
                ),
                trailing: widget.trailing ??
                    new RotationTransition(
                      turns: _iconTurns,
                      child: const Icon(Icons.expand_more),
                    ),
              ),
            ),
          ),
          new ClipRect(
            child: new Align(
              alignment: Alignment.topLeft,
              heightFactor: _easeInAnimation.value,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor.end = widget.borderColor ?? theme.dividerColor;
    _headerColor
      ..begin = theme.textTheme.subhead.color
      ..end = widget.titleColor ?? theme.accentColor;
    _iconColor
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    _backgroundColor.end = widget.backgroundColor;

    final bool closed = !_isExpanded && _controller.isDismissed;
    return new AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed
          ? null
          : Padding(
              padding: widget.expansionPadding,
              child: new Column(children: widget.children),
            ),
    );
  }
}
