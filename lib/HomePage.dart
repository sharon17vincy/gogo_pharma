import 'package:flutter/material.dart';
import 'package:gogo_pharma/CreatePostPage.dart';
import 'package:gogo_pharma/GoGoPharma.dart';
import 'package:gogo_pharma/Helper/HelperPage.dart';
import 'package:gogo_pharma/Models/PostObject.dart';
import 'package:gogo_pharma/ProfilePage.dart';
import 'package:gogo_pharma/Theme.dart';
import 'package:gogo_pharma/Widgets/FeedWidget.dart';
import 'package:gogo_pharma/WinnerPostPage.dart';
import 'package:gogo_pharma/mixins/loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LoadingStateMixin{
  final GoGoPharma goPharma = GoGoPharma.getInstance();
  TextEditingController searchController = TextEditingController();
  late Future future;
  List<Post> post = [];
  Post max = Post();
  String selected = "";
  int selectedId = 1;
  List checkListItems = [
    {
      "id": 0,
      "value": false,
      "title": "Highest",
    },
    {
      "id": 1,
      "value": false,
      "title": "Latest",
    },

  ];


  @override
  void initState() {
    super.initState();
    future = getData();
  }

  Future<bool> getData() async
  {
    await PostHelper().getPosts().then((data) {
      setState(() {
        print(data.length);
        post.clear();
        post.addAll(data);

        calculateWinner();
      });
    }).catchError((error) {
      setLoading(false);
      print(error);
      showSnackBar(error);
    });
    return true;
  }

  void calculateWinner()
  {
    setState(() {
      for(int i=0; i < post.length; i++)
      {
        post[i].total = post[i].likes + post[i].views - post[i].dislikes;
      }
      if (post != null && post.isNotEmpty) {
        max = post.first;
        post.forEach((e) {
          if (e.total > max.total) max = e;
        });
        print("Winner");
        print(max.total);
        if(max.total == 0)
        {
          max = Post();
        }
      }
    });

  }

  sortDialog()
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0x99151515),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content:
          SizedBox(
            height: 200,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter alertState) {
                    return
                      Column(
                        children: [
                          const Text(
                              "Sort By",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              )),
                          SizedBox(height: 16,),
                          Column(
                              mainAxisSize: MainAxisSize.min ,
                              children: List.generate(
                                  checkListItems.length,
                                      (index) => Theme(
                                    data: ThemeData(unselectedWidgetColor: Colors.white),
                                    child: CheckboxListTile(
                                      controlAffinity: ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      activeColor: appTheme.primaryColor,
                                      dense: true,
                                      title: Text(
                                        checkListItems[index]["title"],
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      value: checkListItems[index]["value"],
                                      onChanged: (value) {
                                        alertState(() {
                                          for (var element in checkListItems) {
                                            element["value"] = false;
                                          }
                                          checkListItems[index]["value"] = value;
                                          selectedId = checkListItems[index]["id"];
                                          print(selectedId);

                                          selected =
                                          "${checkListItems[index]["id"]}, ${checkListItems[index]["title"]}, ${checkListItems[index]["value"]}";
                                        });

                                        applyFilter();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ))),
                        ],
                      );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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

  applyFilter()
  {
    setState(() {

        if(selectedId == 0)
        {
          post.sort((a, b) => b.total.compareTo(a.total));
        }
        if(selectedId == 1)
        {
          post.sort((a, b) => b.created.compareTo(a.created));
        }
    });

  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostPage(title: "Create Post",draft: false))).then((value) => getData());
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.cloud_upload,color: Colors.white,),
        ),
        body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              return Stack(
                children: [
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                              // image: max.image.isEmpty ? null : DecorationImage(
                              //   image: NetworkImage(max.image),
                              //   fit: BoxFit.cover,
                              //
                              // ),
                            ),
                            ),
                        flex: 1,
                      ),
                      Expanded(
                        child: Container(color: Colors.black),
                        flex: 6,
                      ),
                    ],
                  ),
                  Container(
                    height: height,
                    padding: const EdgeInsets.only(top: 40, left: 0, right: 0, bottom: 0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Dashboard',
                                style: titleNormalBoldStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then((value) => getData());
                                },
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.black,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(goPharma.user.image,),
                                    child : goPharma.user.image.isNotEmpty ? null : Icon(Icons.person, size: 35,),
                                  ),
                                ),
                              ), // grid,
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Padding(
                                padding: const EdgeInsets.only(top: 25.0, left: 8),
                                child: GestureDetector(
                                  onTap: (){
                                    sortDialog();
                                  },
                                  child: const Icon(Icons.sort_rounded, size: 40, color: Colors.grey,
                                  ),),
                              ),
                              Stack(
                                  children: <Widget>[
                                    Container(
                                      height: 100,
                                      width: 200,

                                      padding: EdgeInsets.only(left: 60),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => WinnerPostPage(title: "Winner", draft: max)));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: ShaderMask(
                                                shaderCallback: (rect) {
                                                  return LinearGradient(
                                                    begin: Alignment(0.0, 0.4),
                                                    end: Alignment(0.0, 1.0),
                                                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                                                  ).createShader(rect);
                                                },
                                                blendMode: BlendMode.srcATop,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  elevation: 15,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[900],
                                                          border: Border.all(color: Colors.white, width: 2),
                                                          gradient: const LinearGradient(
                                                              colors: [
                                                                Colors.black,
                                                                Colors.black54
                                                              ], begin: Alignment.topRight, end: Alignment.bottomLeft
                                                          ),
                                                      borderRadius: BorderRadius.circular(8),
                                                      image: max.total == 0 ? null : DecorationImage(
                                                          image: NetworkImage(max.image),
                                                          fit: BoxFit.cover,

                                                      ),
                                                    ),
                                                    child: max.total == 0 ? Container(
                                                      alignment: Alignment.center,
                                                        height: 100,
                                                        width: 200,
                                                        child: Text(" No Winners", style: TextStyle(color: Colors.grey),)) : null,
                                                  )
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        height: 70,
                                        width: 80,
                                        color: Colors.transparent,
                                        margin: const EdgeInsets.only(left:24, top: 16, bottom: 8),
                                        alignment: FractionalOffset.centerLeft,
                                        child: Image.asset("assets/images/trophy.png"))
                                  ]),
                            ],
                          ),
                        ),
                        Container(
                          height: height * 0.75,
                          width: width,
                          child: ListView.builder(
                            itemCount: post.length,
                            itemBuilder: (context, i)
                            {
                              return makeFeed(userName : post[i].name, userImage: post[i].userImage, feedImage: post[i].image, feedText: post[i].desc ,
                                feedTime : goPharma.timeAgo(post[i].created), dislikes: post[i].dislikes, views: post[i].views , likes: post[i].likes, id: post[i].id, onRefresh: (){
                                getData();
                                },);
                            },
                          ),),

                      ],
                    ),
                  ),
                ],
              );
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
    );
  }

}
