import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  Map post = {};
  bool postUpdated = false;

  String baseUrl = 'http://192.168.0.10:5000';

  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();

  _showSnackBar(String message, Color background) {
    final snackBar = new SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: background,
    );
    _scafoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> _deletePost() async {
    try {
      Dio dio = Dio();
      Response res = await dio.delete('$baseUrl/api/posts/${post['id']}');
      print(res.data);
      Navigator.pop(
        context,
        {
          'deleted': true,
          'postUpdated': postUpdated,
        },
      );
    } catch (err) {
      print(err);
    }
  }

  Future<bool> _willPop() async {
    Navigator.pop(
      context,
      {
        'deleted': false,
        'postUpdated': postUpdated,
      },
    );
    return await Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      key: _scafoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          WillPopScope(
            onWillPop: _willPop,
            child: SliverAppBar(
              title: Text(
                post['title'],
                style: TextStyle(color: Colors.red),
              ),
              pinned: true,
              floating: false,
              expandedHeight: 200.0,
              // automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  post['imageUrl'] != ""
                      ? post['imageUrl']
                      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQQNSc7FL3cySc2Ge2WUuj7b19uynoYcpSSF9ZjflDAYyBZBqeQ',
                  fit: BoxFit.cover,
                ),
              ),
              iconTheme: IconThemeData(color: Colors.amber),
            ),
          ),
          SliverFillRemaining(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    post['body'],
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(
                        'Created on: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        post['createdAt'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  post['createdAt'] != post['updatedAt']
                      ? Row(
                          children: <Widget>[
                            Text(
                              'Updated on: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              post['updatedAt'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(height: 0),
                  RaisedButton(
                    onPressed: _deletePost,
                    color: Colors.red,
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: _postFab(),
    );
  }

  FloatingActionButton _postFab() => FloatingActionButton(
        onPressed: () async {
          dynamic res = await Navigator.pushNamed(
            context,
            '/post-add-edit',
            arguments: {
              'post': post,
              'type': 'edit',
            },
          );
          print(res);
          if (!res.isEmpty) {
            _showSnackBar('Post Updated Successfully.', Colors.green);
            setState(
              () {
                postUpdated = true;
                post['title'] = res['title'];
                post['imageUrl'] = '$baseUrl${res['imageUrl']}';
                post['body'] = res['body'];
                post['createdAt'] = DateFormat.yMMMMd()
                    .format(DateTime.parse(res['createdAt']));
                post['updatedAt'] = DateFormat.yMMMMd()
                    .format(DateTime.parse(res['updatedAt']));
                post['id'] = res['_id'];
              },
            );
          }
        },
        child: Center(
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(
          0xff35CC2E,
        ),
      );
}
