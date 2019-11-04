import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    changePage();
  }

  changePage() async {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(
        context,
        '/posts',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Box decoration takes a gradient
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.5, 0.7, 0.9],
          colors: [
            Color(0xff41D43A),
            Color(0xff3498DB),
            Color(0xff5DADE2),
            Color(0xff2471A3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/node.png',
              height: 100.0,
            ),
            SizedBox(height: 10.0),
            Image.asset(
              'assets/images/flutter.png',
              height: 100.0,
            ),
          ],
        ),
      ),
    );
  }
}
