import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VerticalDragUpdater extends StatefulWidget {
  final Widget _content;
  final Function? _onUpdate;

  VerticalDragUpdater({required Widget content, Function? onUpdate})
      : _content = content,
        _onUpdate = onUpdate;

  @override
  State<StatefulWidget> createState() {
    return VerticalDragUpdaterState();
  }
}

class VerticalDragUpdaterState extends State<VerticalDragUpdater> {
  double _dragProgress = 0.0;
  double _dragStart = 0.0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (info) => _dragStart = info.localPosition.dy,
      onPointerMove: (info) {
        setState(() {
          double diff = info.localPosition.dy - _dragStart;
          _dragProgress = max(0, diff / 100);
        });
      },
      onPointerUp: (info) {
        if (_dragProgress >= 1.0) {
          widget._onUpdate!();
        }
        setState(() => _dragProgress = 0);
      },
      child: Stack(
        children: [
          widget._content,
          Center(
            heightFactor: 2,
            child: Transform.scale(
              origin: Offset(0, -40),
              scale: min(1, _dragProgress),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Transform.scale(
                  scale: 0.65,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    value: _dragProgress,
                    backgroundColor: Colors.white,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
