import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/Helper/HelperPage.dart';
import 'package:gogo_pharma/Models/PostObject.dart';
import 'package:gogo_pharma/Theme.dart';
import 'package:gogo_pharma/Widgets/Functions.dart';
import 'package:gogo_pharma/Widgets/SolidButton.dart';
import 'package:gogo_pharma/mixins/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WinnerPostPage extends StatefulWidget {
  const WinnerPostPage({Key? key, required this.title, required this.draft}) : super(key: key);
  final String title;
  final Post draft;

  @override
  State<WinnerPostPage> createState() => _WinnerPostPageState();
}

class _WinnerPostPageState extends State<WinnerPostPage> with LoadingStateMixin{
  TextEditingController messageController = TextEditingController();
  final imgPicker = ImagePicker();
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  String? imgFile, image = "";
  final GoGoPharma goPharma = GoGoPharma.getInstance();

  @override
  void initState() {
    super.initState();
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


  void openCamera() async {
    var imgGallery = await imgPicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear
    );
    if (imgGallery != null) {
      var bytesFile = await imgGallery.readAsBytes();
      var bytes = bytesFile.lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb > 5) {
        showSnackBar('File Size too big');
      } else {
        setState(() {
          imgFile = imgGallery.path;
        });
      }
    }
  }

  Future<void> uploadImage() async {
    String imageUrl = "";
    setLoading(true);

    if (image != null)
    {
      //Upload to Firebase
      final _firebaseStorage = FirebaseStorage.instance;
      var snapshot = await _firebaseStorage.ref()
          .child('images/' + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(File(image!));
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(()
      {
        imageUrl = downloadUrl;
        print("Url : $imageUrl");
        publishPosts(imageUrl);
      });
    }
    else
    {
      print('No Image Path Received');
    }
  }

  Future<bool> publishPosts(String imageUrl) async {
    print("Publish posts");


    await PostHelper().createPost(imageUrl, goPharma.user.name, messageController.text).then((data) {
      setState(() {
        // showSnackBar("Post added successfully");
        setLoading(false);
        Navigator.pop(context);
        showToast("Photo uploaded successfully!", context);

      });
    }).catchError((error) {
      setLoading(false);
      print(error);
      showSnackBar(error);
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 80),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.grey,)),
                  const SizedBox(width: 16,),
                  const Text("Winner", style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(height: 30,),
              Container(
                height: height/1.3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey
                              ),
                              child: CircleAvatar(
                                radius: 55.0,
                                backgroundImage: NetworkImage(widget.draft.userImage,),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(widget.draft.name , style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: 'Total Points : ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                        TextSpan(
                                            text: widget.draft.total.toString(),
                                            style: TextStyle(color: appTheme.primaryColor, fontSize: 14)
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                            height: 70,
                            width: 80,
                            color: Colors.transparent,
                            alignment: FractionalOffset.centerLeft,
                            child: Image.asset("assets/images/trophy.png")),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      height: 0.5,
                    ),
                    const SizedBox(height: 10,),
                    InteractiveViewer(
                          child: Container(
                      height: height/1.7,
                      width: width/1.1,
                      child: Image.network(
                          widget.draft.image,
                          fit: BoxFit.cover,
                      ),
                    ),
                        )
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              Text(widget.draft.desc , style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),),

            ])),
      ),
    );
  }


}