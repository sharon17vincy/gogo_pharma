import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/Helper/HelperPage.dart';
import 'package:gogo_pharma/Theme.dart';
import 'package:gogo_pharma/Widgets/Functions.dart';
import 'package:gogo_pharma/Widgets/SolidButton.dart';
import 'package:gogo_pharma/mixins/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key, required this.title, required this.draft}) : super(key: key);
  final String title;
  final bool draft;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> with LoadingStateMixin{
  TextEditingController messageController = TextEditingController();
  final imgPicker = ImagePicker();
  String? imgFile, image = "";
  final GoGoPharma goPharma = GoGoPharma.getInstance();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    imgFile = widget.draft ? goPharma.draft : null;
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
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 30),
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
                  const Text("Create Post", style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),),
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
                              child: goPharma.user.image.isEmpty ? Icon(Icons.person) : CircleAvatar(
                                radius: 55.0,
                                backgroundImage: NetworkImage(goPharma.user.image,),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(goPharma.user.name , style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: 'Privacy : ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                        TextSpan(
                                            text: 'Public ',
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
                        GestureDetector(
                            onTap: (){
                              setState(() {
                                openCamera();
                              });
                            },
                            child: const Icon(Icons.camera_alt, size: 30, color: Colors.white,)),
                      ],
                    ),
                    SizedBox(height: height * 0.03,),
                    Container(
                      height: height * 0.10,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8)),
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(color: focusNode.hasFocus ? Colors.white : Colors.grey, fontSize: 18, ),
                        enabled:  true,
                        maxLength: 50,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(width: 1, color: Colors.transparent),
                            ),
                            contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Whats new, " + goPharma.user.name + "?" ,
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
                          //    prefixIcon: Icon(Icons.person,color: colorblue,),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      height: 0.5,
                    ),
                    const SizedBox(height: 10,),
                    imgFile != null
                        ? InteractiveViewer(
                          child: Container(
                      height: height/2.5,
                      width: width/1.1,
                      child: Image.file(
                          File(imgFile.toString()),
                          fit: BoxFit.cover,
                      ),
                    ),
                        ) : Container(),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        List img = [];
                        // img = prefs.getStringList('images')!;
                        if(prefs.getStringList('images') != null)
                        {
                          img.addAll(prefs.getStringList('images')!);
                        }
                        if(goPharma.draft != imgFile)
                        {
                          img.remove(goPharma.draft);
                          img.add(imgFile.toString());
                          prefs.setStringList('images', img.cast<String>());
                        }
                        else if(!img.contains(imgFile))
                        {
                          img.add(imgFile.toString());
                          prefs.setStringList('images', img.cast<String>());
                        }
                        print(img);
                        Navigator.pop(context);
                      },
                      child: SolidButton(title : "Save as Draft", loading: loading, width:  width/2.5, solid: true,onTap: (){},)
                    ),
                    GestureDetector(
                      onTap: () async {
                        if(widget.draft)
                        {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          List img = [];
                          // img = prefs.getStringList('images')!;
                          if(prefs.getStringList('images') != null)
                          {
                            img.addAll(prefs.getStringList('images')!);
                          }
                          img.remove(goPharma.draft);
                          prefs.setStringList('images', img.cast<String>());
                        }
                        image = imgFile;
                        if(imgFile == null)
                        {
                          showSnackBar("Please add photo");
                        }
                        if(messageController.text.isEmpty)
                        {
                          showSnackBar("Please type the message");
                        }
                        else
                        {
                          uploadImage();
                        }
                      },
                      child: SolidButton(title : "Post", loading: loading, width:  width/2.5, solid: true,onTap: (){},)),
                  ],
                ),
              ),
            ])),
      ),
    );
  }


}