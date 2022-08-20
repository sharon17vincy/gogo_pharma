import 'package:flutter/material.dart';

Widget makeLike() {
  return Container(
    width: 20,
    height: 20,
    decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        // border: Border.all(color: Colors.white)
    ),
    child: const Center(
      child: Icon(Icons.thumb_up, size: 12, color: Colors.white),
    ),
  );
}

Widget makeDisLike() {
  return Container(
    width: 20,
    height: 20,
    decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        // border: Border.all(color: Colors.white)
    ),
    child: const Center(
      child: Icon(Icons.thumb_down, size: 12, color: Colors.white),
    ),
  );
}

Widget views() {
  return Container(
    width: 20,
    height: 20,
    decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        // border: Border.all(color: Colors.white)
    ),
    child: const Center(
      child: Icon(Icons.remove_red_eye, size: 12, color: Colors.white),
    ),
  );
}
