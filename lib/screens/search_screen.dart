import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/Utils/colors.dart';
import 'package:instagram_clone/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            label: Text('Search for User'),
          ),
          onFieldSubmitted: (String _){
            print(_);
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: isShowUsers? FutureBuilder(
        future: FirebaseFirestore.instance.collection('user').where('username',isGreaterThanOrEqualTo: searchController.text).get(),
        builder: (context , AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
          if(!snapshot.hasData){
            return CircularProgressIndicator(color: Colors.white,);
          }

          return ListView.builder(
          itemCount: snapshot.data!.docs.length,
            itemBuilder: (context , index){
              return InkWell(
                onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(uid: snapshot.data!.docs[index]['uid'])));},
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!.docs[index]['photoUrl']),
                  ),
                  title: Text(snapshot.data!.docs[index]['username']),
                ),
              );
            },
          );
        },
      ) : FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator(color: Colors.white,),);
          }

          return StaggeredGridView.countBuilder(
            crossAxisCount: 3,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) =>Image.network(snapshot.data!.docs[index]['photoUrl']),
              staggeredTileBuilder: (int index) => StaggeredTile.count(
            (index % 7) == 0 ? 2 : 1,
            (index % 7) == 0 ? 2 : 1,
          ),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          );
        },
      ),
    );
  }
}
