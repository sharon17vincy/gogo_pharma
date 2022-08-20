import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/Models/PostObject.dart';



class PostHelper {
  final GoGoPharma goPharma = GoGoPharma.getInstance();

  Future<bool> createPost(String url,String name, String desc,) async
  {
    FirebaseFirestore.instance.collection("posts").add({
      "image" : url,
      "name" : name,
      "desc" : desc,
      "created_at" : DateTime.now().toString(),
      "likes" : 0,
      "dislikes" : 0,
      "views" : 0,
      "userImage" : goPharma.user.image
    }).then((value) {
      print(value);
      return true;
    }).catchError((error) {
      print("Failed to add post");
      return "Failed to add post";
    });

    return true;
  }

  Future<List<Post>> getPosts() async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('posts').orderBy("created_at", descending: true)
        .get();

    List<Post> allData =  [];

    for (var message in querySnapshot.docs.toList()) {
      print(message.data());
      Post post = Post();
      post.id = message.id;
      post.name = message.get('name');
      post.image = message.get('image');
      post.userImage = message.get('userImage');
      post.created = message.get('created_at');
      post.dislikes = message.get('dislikes');
      post.views = message.get('views');
      post.likes = message.get('likes');
      post.desc = message.get('desc');

      allData.add(post);

    }
    print(allData);

    return allData;

  }

  Future<List<Post>> getUserPosts() async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('posts').where('name', isEqualTo: goPharma.user.name).get();

    List<Post> allData =  [];

    for (var message in querySnapshot.docs.toList()) {
      print(message.data());
      Post post = Post();
      post.id = message.id;
      post.name = message.get('name');
      post.image = message.get('image');
      post.userImage = message.get('userImage');
      post.created = message.get('created_at');
      post.dislikes = message.get('dislikes');
      post.views = message.get('views');
      post.likes = message.get('likes');
      post.desc = message.get('desc');

      allData.add(post);

    }

    print(allData);

    return allData;

  }


  Future<bool> updateLike(String id, int count) async
  {
    FirebaseFirestore.instance.collection('posts').doc(id).update({'likes': count}).then((value) {
      // print(value);
      return true;
    }).catchError((error) {
      print("Failed to update like");
      return "Failed to update like";
    });

    return true;

  }

  Future<bool> updateDislike(String id, int count) async
  {
    FirebaseFirestore.instance.collection('posts').doc(id).update({'dislikes': count}).then((value) {
      // print(value);
      return true;
    }).catchError((error) {
      print("Failed to update dislike");
      return "Failed to update dislike";
    });

    return true;

  }

  Future<bool> updateViews(String id, int count) async
  {
    FirebaseFirestore.instance.collection('posts').doc(id).update({'views': count}).then((value) {
      // print(value);
      return true;
    }).catchError((error) {
      print("Failed to update views");
      return "Failed to update views";
    });

    return true;

  }

}
