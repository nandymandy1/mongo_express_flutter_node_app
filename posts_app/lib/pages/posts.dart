import 'package:flutter/material.dart';
import 'package:posts_app/classes/PostClass.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  List<PostClass> posts;
  bool loading = false;

  String baseUrl = 'http://192.168.0.10:5000';
  // String baseUrl = 'http://192.168.0.128:5000';

  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();

  _showSnackBar(String message, Color background) {
    final snackBar = new SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: background,
    );
    _scafoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> getPosts() async {
    posts = [];
    List<PostClass> apiPosts = [];
    try {
      setState(() {
        loading = true;
      });
      Response res = await get('$baseUrl/api/posts');
      List data = jsonDecode(res.body);
      for (int i = 0; i < data.length; i++) {
        PostClass instance = PostClass(
          body: data[i]['body'],
          title: data[i]['title'],
          id: data[i]['_id'],
          imageUrl: data[i]['imageUrl'] != null
              ? '$baseUrl${data[i]['imageUrl']}'
              : '',
          createdAt: data[i]['createdAt'],
          updatedAt: data[i]['updatedAt'],
        );
        apiPosts.add(instance);
      }
      setState(
        () {
          posts = apiPosts;
          loading = false;
        },
      );
    } catch (error) {
      print(error);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Posts'),
        backgroundColor: Color(0xff35CC2E),
      ),
      body: RefreshIndicator(
        child: posts.length == 0 ? _scrollView() : _renderPosts(),
        onRefresh: getPosts,
      ),
      floatingActionButton: _renderFAButton(),
    );
  }

  Center _scrollView() => Center(
        child: loading
            ? _renderLoader()
            : Text(
                "No Posts Found",
              ),
      );

  CircularProgressIndicator _renderLoader() => CircularProgressIndicator(
        backgroundColor: Colors.white,
        strokeWidth: 5.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          Color(0xff35CC2E),
        ),
      );

  Padding _renderPosts() => Padding(
        child: Container(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => _postsCard(posts[index]),
          ),
        ),
        padding: const EdgeInsets.all(6.0),
      );

  Card _postsCard(PostClass post) => Card(
        child: ListTile(
          title: Text(post.title),
          subtitle: _postDescription(post.body),
          leading: _renderImage(post.imageUrl),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          onTap: () async {
            dynamic res = await Navigator.pushNamed(
              context,
              '/post',
              arguments: {
                'id': post.id,
                'body': post.body,
                'title': post.title,
                'imageUrl': post.imageUrl,
                'createdAt': post.createdAt,
                'updatedAt': post.updatedAt,
              },
            );
            if (res['deleted']) {
              _showSnackBar('Post Deleted Successfully.', Colors.green);
              setState(() {
                posts = posts.where((po) => po.id != post.id).toList();
              });
            }
            if (res['postUpdated']) {
              getPosts();
            }
          },
        ),
      );

  Image _renderImage(String url) => url != ''
      ? Image.network(
          url,
          height: 200,
        )
      : Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQQNSc7FL3cySc2Ge2WUuj7b19uynoYcpSSF9ZjflDAYyBZBqeQ',
          height: 200,
        );

  Text _postDescription(String description) {
    try {
      return Text(description.substring(0, 65));
    } catch (error) {
      return Text(
        description.substring(0, description.length),
      );
    }
  }

  FloatingActionButton _renderFAButton() => FloatingActionButton(
        backgroundColor: Color(0xff35CC2E),
        onPressed: () async {
          dynamic res = await Navigator.pushNamed(
            context,
            '/post-add-edit',
            arguments: {'post': post, 'type': 'add'},
          );
          if (!res.isEmpty) {
            PostClass newPost = PostClass(
              id: res['_id'],
              body: res['body'],
              title: res['title'],
              createdAt: res['createdAt'],
              updatedAt: res['updatedAt'],
              imageUrl:
                  res['imageUrl'] != null ? '$baseUrl${res['imageUrl']}' : '',
            );
            setState(() {
              posts.add(newPost);
            });
            _showSnackBar('Post Created Successfully.', Colors.green);
          }
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      );
}
