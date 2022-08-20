import 'package:flutter/material.dart';

mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    setState(() {
      this._loading = value;
    });
  }

  setLoading(bool value) {
    FocusScope.of(context).unfocus();
    setState(() {
      this._loading = value;
    });
  }
}
