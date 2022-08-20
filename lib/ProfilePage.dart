import 'dart:io';
import 'package:gogo_pharma/Models/UserObject.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/CreatePostPage.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/Helper/HelperPage.dart';
import 'package:gogo_pharma/LoginPage.dart';
import 'package:gogo_pharma/Models/PostObject.dart';
import 'package:gogo_pharma/Theme.dart';
import 'package:gogo_pharma/Widgets/Functions.dart';
import 'package:gogo_pharma/mixins/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({Key? key, }) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with LoadingStateMixin
{
  final GoGoPharma goPharma = GoGoPharma.getInstance();
  List<String> imagesDraft = [];
  final imgPicker = ImagePicker();
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffe43e68), Color(0xfffaa449)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  String? imgFile, image = "";

  String selected = "Posts";

  List<Post> post = [];
  late Future future;


  @override
  void initState() {
    super.initState();
    future = getPost();
  }

  void showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white,),
      ),
      backgroundColor: Colors.orange,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: appTheme.accentColor,
        disabledTextColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

  Future<void> getData()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      imagesDraft.clear();
      if(prefs.getStringList('images') != null) {
        imagesDraft.addAll(prefs.getStringList('images')!);
      }
    });

    print("Draft images count : ${imagesDraft.length}");
  }

  Future<bool> getPost() async
  {
    // setLoading(true);
    await PostHelper().getUserPosts().then((data) {
      setState(() {
        print(data.length);
        post.clear();
        post.addAll(data);
      });
    }).catchError((error) {
      // setLoading(false);
      print(error);
      showSnackBar(error);
    });
    return true;
  }

  Future<void> uploadImage() async {
    String imageUrl = "";

    if (imgFile != null)
    {
      //Upload to Firebase
      final _firebaseStorage = FirebaseStorage.instance;
      var snapshot = await _firebaseStorage.ref()
          .child('profile_images/' + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(File(imgFile!));
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(()
      {
        imageUrl = downloadUrl;
        print("Url : $imageUrl");
        setState(() {

          FirebaseAuth.instance.currentUser!.updatePhotoURL(imageUrl).then((value){
            print("Profile has been changed successfully");
            goPharma.user.image = FirebaseAuth.instance.currentUser!.photoURL!;
            //DO Other compilation here if you want to like setting the state of the app
          }).catchError((e){
            print("There was an error updating profile");
          });
        });
      });
    }
    else
    {
      print('No Image Path Received');
    }
  }

  void openGallery() async {
    var imgGallery = await imgPicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (imgGallery != null) {
      var bytesFile = await imgGallery.readAsBytes();
      var bytes = bytesFile.lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb > 5) {
        showSnackBar('File Size too big');
      } else {
        imgFile = imgGallery.path;
        await uploadImage();

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              goPharma.user = UserObject();
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("user", "");
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const LoginPage(title: "Login")));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.logout,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xffe43e68), Color(0xfffaa449)],
                        ),
                        borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.orange, width: 3)
                      ),
                      child: imgFile != null
                          ? CircleAvatar(
                           backgroundImage: FileImage( File(imgFile.toString()),
                           ),
                      ) : goPharma.user.image.isNotEmpty ? CircleAvatar(
                        radius: 55.0,
                        backgroundImage: NetworkImage(goPharma.user.image,),
                        backgroundColor: Colors.transparent,
                      ) : Icon(Icons.person, color: Colors.white, size: 50,),
                    ),
                    Positioned(
                      bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: (){
                            openGallery();
                          },
                          child: Container(
                            height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange
                              ),
                              child: Icon(Icons.add, size: 25, color: Colors.white,)),
                        ))
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      goPharma.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      goPharma.user.email,
                      style: const TextStyle(
                        fontSize: 15,
                          color: Colors.grey

                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 30,
                        width: width/3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xffe43e68),
                              Color(0xfffaa449)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostPage(title: "Create Post", draft: false,))).then((value) => getData());
                          },
                          child: const Center(
                            child: Text(
                              'Upload',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Column(
              children: [
                const Divider(
                  thickness: 1,
                  color: Colors.white10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          post.length.toString(),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const Text(
                          'posts',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: const [
                        Text(
                          '100',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          'followers',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: const [
                        Text(
                          '132',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          'following',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.white10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 00.0, left: 24, right: 24, bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: appTheme.primaryColor, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8)
                        )),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              selected = "Posts";
                              getPost();
                            });
                          },
                          child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: MediaQuery.of(context).size.width/2.25,
                              color: selected == "Posts" ? appTheme.primaryColor : Colors.transparent,
                              child: Text("Posts", textAlign: TextAlign.center, style: TextStyle(color: selected == "Posts" ? Colors.white : appTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),)),
                        ),
                        Container(height: 40,width : 1.5, color: appTheme.primaryColor,),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              selected = "Draft";
                              getData();
                            });
                          },
                          child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: MediaQuery.of(context).size.width/2.34,
                              color: selected == "Draft" ? appTheme.primaryColor : Colors.transparent,
                              child: Text("Draft", style: TextStyle(color: selected == "Draft" ? Colors.white : appTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  height: height/1.78,
                  child: FutureBuilder(
                      future: future,
                      builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.waiting) {
                      return GridView.builder(
                      padding: EdgeInsets.only(top: 8, bottom: 16),
                      shrinkWrap: true,
                      primary: false,
                      itemCount: selected == "Posts" ? post.length : imagesDraft.length,
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () async {
                            if(selected == "Posts")
                            {
                              await showImageDialog(context, post[index].image);
                            }
                            else
                            {
                              goPharma.draft = imagesDraft[index];
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostPage(title: "Create Post", draft: true,))).then((value) => getData());
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(15),
                                image: selected == "Posts" ? DecorationImage(image: NetworkImage(post[index].image),fit: BoxFit.cover) : DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    File(imagesDraft[index].toString()),
                                  ),
                                )
                              ),
                            ),
                          ),
                        );
                      });
                      }
                      return Container(
                        color: Colors.black,
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: appTheme.primaryColor,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                      },
                  )
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}