import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Utils/colors.dart';
import 'package:instagram_clone/Utils/utils.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});


  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int com_len = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('posts').doc(widget.snap['postId']).collection('comments').get();
    com_len = snap.docs.length;
    setState(() {
      com_len = com_len;
    });
  }

  bool redHeart(){
    bool res = false ;
    if(widget.snap['likes'].contains(widget.snap['uid'])){
      res =  true;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {

    bool _isLoading = false;

    bool isLikeAnimating = false;

    final User user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: mobileBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        //HEADER SECTION
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.snap['profImage']),

                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${widget.snap['username']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(onPressed: () {
                  showDialog(context: context, builder: (context) => Dialog(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shrinkWrap: true,
                      children: [
                        _isLoading? CircularProgressIndicator(color: Colors.white,) :
                        'Delete',
                      ].map((e) => InkWell(
                        onTap: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          String res = await FirestoreMethods().deletePost(widget.snap['postId']);
                          if(res == 'Successful!'){
                            showSnackBar('Successfully deleted your Hardwork!', context);
                            setState(() {
                              _isLoading = false;
                            });
                          }
                          else{
                            showSnackBar('Some error occured!', context);
                            setState(() {
                              _isLoading = false;
                            });
                          }
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                          child: Center(child: Text('$e')),
                        ),
                      )).toList(),
                    ),
                  ));
                }, icon: const Icon(Icons.more_vert)),

              ],
            ),
          ),
          // IMAGE SECTION
          GestureDetector(
            onTap: () {},
            onDoubleTap: () async {
              await FirestoreMethods().likePost(widget.snap['postId'], widget.snap['uid'], widget.snap['likes']);
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.35,
                  width: double.infinity,
                  child: Image.network('${widget.snap['photoUrl']}',fit: BoxFit.fitHeight,),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(child: const Icon(Icons.favorite , color: Colors.white, size: 120,), duration: Duration(milliseconds: 400), isAnimating: isLikeAnimating, onEnd: () {
                    setState(() {
                      isLikeAnimating = false;
                    });
                  }, smallLike: false),
                )
              ],
            ),
          ),

          // LIKE COMMENT SECTION
          Row(
            children: [
              LikeAnimation(isAnimating: widget.snap['likes'].contains(widget.snap['uid']), smallLike: true , duration: Duration(),
              onEnd: () {  },
              child: IconButton(onPressed: () async {
                await FirestoreMethods().likePost(widget.snap['postId'], widget.snap['uid'], widget.snap['likes']);
                setState(() {
                  isLikeAnimating = true;
                });
              }, icon: redHeart()?Icon(Icons.favorite,color: Colors.red ,): Icon(Icons.favorite_border,color: Colors.white ,))),
              IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommentsScreen(
                snap: widget.snap,
              ))), icon: Icon(Icons.comment,)),
              IconButton(onPressed: () {}, icon: Icon(Icons.send,)),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border,)),
                ),
              )
            ],
          ),
          //DESCRIPTION AND NO. OF COMMENTS
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  child: Text(
                    '${widget.snap['likes'].length} Likes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
                ),
                //////////////////////////    4:05:27
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white),
                      children:[
                        TextSpan(
                          text: '${widget.snap['username']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          //onEnter: Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommentsScreen(snap: widget.snap)))
                        ),
                        TextSpan(
                            text: '  ${widget.snap['description']}',
                            style: TextStyle(fontWeight: FontWeight.normal,),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommentsScreen(snap: widget.snap))),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('View all $com_len comments' , style: TextStyle(fontSize: 13, color: secondaryColor),),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
                    style: TextStyle(fontSize: 13, color: secondaryColor),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
