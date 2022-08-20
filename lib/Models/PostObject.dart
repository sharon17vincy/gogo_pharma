  class Post {
      var id = "";
      var name = "";
      var image = "";
      var userImage = "";
      var desc  = "";
      var created = "";
      var views = 0;
      var likes = 0;
      var dislikes = 0;
      var total = 0;

      Post() {
    id = id;
    name = name;
    image = image;
    userImage = userImage;
    desc = desc;
    created = created;
    views = views;
    likes = likes;
    dislikes = dislikes;
    total = total;
  }

  Post.fromJson(Map json)
      : id = json["id"] ?? "",
        name = json["name"] ?? "",
        image = json['image'] ?? "",
        userImage = json["userImage"] ?? "",
        desc = json['desc'] ?? "",
        created = json['created'] ?? "",
        views = json['views'] ?? 0,
        likes = json['likes'] ?? 0,
        dislikes = json["dislikes"] ?? 0,
        total = json["total"] ?? 0;

  }

