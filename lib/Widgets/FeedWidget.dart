import 'package:flutter/material.dart';
import 'package:gogo_pharma/Helper/HelperPage.dart';
import 'package:gogo_pharma/Models/PostObject.dart';
import 'package:gogo_pharma/Widgets/FeedButtons.dart';
import 'package:gogo_pharma/Widgets/Functions.dart';


import '../Theme.dart';

class makeFeed extends StatefulWidget {
  const makeFeed({Key? key, required this.userImage, required this.userName, required this.feedText, required this.feedImage, required this.feedTime,
  required this.dislikes, required this.views, required this.likes, required this.id, required this.onRefresh}) : super(key: key);
  final String userName;
  final String userImage;
  final String feedTime;
  final String feedText;
  final String feedImage;
  final int dislikes;
  final int views;
  final int likes;
  final String id;
  final VoidCallback onRefresh;


  @override
  State<makeFeed> createState() => _makeFeedState();
}

class _makeFeedState extends State<makeFeed>{

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
      backgroundColor: Colors.black,
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

  Future<bool> updateLike() async
  {
    await PostHelper().updateLike(widget.id, widget.likes + 1).then((data) {
      setState(() {
        widget.onRefresh();
      });
    }).catchError((error) {
      print(error);
      showSnackBar(error);
    });
    return true;
  }

  Future<bool> updateDisLike() async
  {
    await PostHelper().updateDislike(widget.id, widget.dislikes + 1).then((data) {
      setState(() {
        widget.onRefresh();
      });
    }).catchError((error) {
      print(error);
      showSnackBar(error);
    });
    return true;
  }

  Future<bool> updateViews() async
  {
    await PostHelper().updateViews(widget.id, widget.views + 1).then((data) {
      setState(() {
        widget.onRefresh();
      });
    }).catchError((error) {
      print(error);
      showSnackBar(error);
    });
    return true;
  }


  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          color: Colors.black,
          // borderRadius: BorderRadius.all(Radius.circular(15.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.white10,
              blurRadius: 4,
              offset: Offset(-2, 3), // Shadow position
            ),
          ],
        ),
        margin: const EdgeInsets.only(top: 0, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: widget.userImage.isEmpty ? Icon(
                      Icons.person, color: Colors.white,) : CircleAvatar(
                      radius: 55.0,
                      backgroundImage: NetworkImage(widget.userImage),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(child: Text(widget.userName, softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,),)),
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.35,
                    child: Text((widget.feedTime), textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 13, color: Colors.grey),),
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            // Text(widget.feedText, maxLines: 3, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5, letterSpacing: .7),),
            widget.feedImage != '' ?
            GestureDetector(
              onTap: () async {
                updateViews();
                await showImageDialog(context, widget.feedImage);
              },
              // onPanUpdate: (details){
              //   updateViews();
              // },
              child: Container(
                  height: 250,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InteractiveViewer(
                      child: Image.network(
                        widget.feedImage, fit: BoxFit.cover,))
              ),
            ) : Container(),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          updateLike();
                        },
                        child: Row(
                          children: [
                            makeLike(),
                            const SizedBox(width: 4,),
                            Text("${widget.likes} likes", style: TextStyle(
                                fontSize: 14, color: Colors.grey),),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          updateDisLike();
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 4,),
                            makeDisLike(),
                            const SizedBox(width: 4,),
                            Text("${widget.dislikes} Dislikes",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey),),
                            const SizedBox(width: 4,),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          views(),
                          const SizedBox(width: 4,),
                          Text("${widget.views} views", style: TextStyle(
                              fontSize: 14, color: Colors.grey),),
                          const SizedBox(width: 4,),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),

            Container(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(widget.feedText,
                  style: const TextStyle(fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                      letterSpacing: .7),)
            ),

          ],
        ),
      ),
    );
  }
}