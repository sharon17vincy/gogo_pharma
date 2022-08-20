

import 'package:gogo_pharma/Models/UserObject.dart';

class GoGoPharma {
  static final GoGoPharma ourInstance = GoGoPharma();

  static GoGoPharma getInstance() {
    return ourInstance;
  }

  UserObject user = UserObject();
  String draft = "";



  String timeAgo(String d) {
    DateTime time = DateTime.parse(d);
    Duration diff = DateTime.now().difference(time);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hr" : "hrs"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "min" : "mins"} ago";
    }
    return "just now";
  }




}



