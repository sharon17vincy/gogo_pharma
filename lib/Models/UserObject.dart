  class UserObject {
      var token = "";
      var name = "";
      var image = "";
      var email  = "";


      UserObject() {
        token = token;
        name = name;
        image = image;
        email = email;

  }

      UserObject.fromJson(Map json)
      : token = json["token"] ?? "",
        name = json["name"] ?? "",
        image = json['image'] ?? "",
        email = json['email'] ?? "";

  }

