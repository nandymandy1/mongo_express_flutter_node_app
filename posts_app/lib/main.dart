import 'package:flutter/material.dart';
import 'package:posts_app/pages/loading.dart';
import 'package:posts_app/pages/posts.dart';
import 'package:posts_app/pages/post.dart';
import 'package:posts_app/pages/ae_posts.dart';

void main() => runApp(
      MaterialApp(
        routes: {
          '/': (context) => Loading(),
          '/posts': (context) => Posts(),
          '/post': (context) => Post(),
          '/post-add-edit': (context) => AddEdit()
        },
        initialRoute: '/',
        theme: ThemeData(
          accentColor: Colors.greenAccent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
    );
