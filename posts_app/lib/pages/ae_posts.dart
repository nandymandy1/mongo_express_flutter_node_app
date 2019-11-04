import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class AddEdit extends StatefulWidget {
  @override
  _AddEditState createState() => _AddEditState();
}

class _AddEditState extends State<AddEdit> {
  String title;
  String body;
  String id;
  File _imageFile;
  String action;

  bool loading = false;

  String baseUrl = 'http://192.168.0.10:5000';
  // String baseUrl = 'http://192.168.0.128:5000';

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = selected;
    });
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );
    setState(() {
      _imageFile = cropped;
    });
  }

  Future<void> submitPost() async {
    String apiUrl = '$baseUrl/api/posts';
    Dio dio = Dio();
    FormData formData = FormData.fromMap(
      {
        "title": title,
        "body": body,
        "postImage": _imageFile != null
            ? await MultipartFile.fromFile(
                _imageFile.path,
                filename: 'flutter-image.png',
              )
            : null,
      },
    );
    setState(() {
      loading = true;
    });

    Response res = await dio.post(apiUrl, data: formData);
    setState(() {
      loading = false;
    });

    Map data = res.data;
    Navigator.pop(context, data);
  }

  Future<void> editPost(String id) async {
    String apiUrl = '$baseUrl/api/posts/$id';
    Dio dio = Dio();
    FormData formData = FormData.fromMap(
      {
        "title": title,
        "body": body,
        "postImage": _imageFile != null
            ? await MultipartFile.fromFile(
                _imageFile.path,
                filename: 'flutter-image.png',
              )
            : null,
      },
    );
    setState(() {
      loading = true;
    });
    Response res = await dio.put(apiUrl, data: formData);
    setState(() {
      loading = false;
    });
    Map data = res.data;
    Navigator.pop(context, data);
  }

  Future<bool> _popView() async {
    Navigator.pop(context, {});
    return await Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    action = args['type'];
    if (action == 'edit') {
      title = args['post']['title'];
      body = args['post']['body'];
      id = args['post']['id'];
    } else {
      title = "";
      body = "";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          action == 'edit' ? 'Edit Post' : 'Create Post',
        ),
        backgroundColor: Color(0xff35CC2E),
      ),
      body: WillPopScope(
        onWillPop: _popView,
        child: Container(
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: title.length != 0 ? title : '',
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (input) =>
                            input.length == 0 ? 'Title is required' : null,
                        onSaved: (input) => title = input,
                      ),
                      TextFormField(
                        maxLines: 8,
                        initialValue: body.length != 0 ? body : '',
                        decoration: InputDecoration(labelText: 'Body'),
                        validator: (input) =>
                            input.length == 0 ? 'Body is required' : null,
                        onSaved: (input) => body = input,
                      ),
                      SizedBox(height: 20.0),
                      _imageFile != null
                          ? Column(children: [
                              Image.file(
                                _imageFile,
                                fit: BoxFit.cover,
                              ),
                              Row(
                                children: <Widget>[
                                  FlatButton(
                                    child: Icon(Icons.crop),
                                    onPressed: _cropImage,
                                  ),
                                  FlatButton(
                                    child: Icon(Icons.refresh),
                                    onPressed: () {
                                      setState(() {
                                        _imageFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ])
                          : SizedBox(
                              height: 1,
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                            color: Color(0xff35CC2E),
                            child: Icon(
                              Icons.photo_library,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          RaisedButton(
                            color: Color(0xff35CC2E),
                            child: Icon(
                              Icons.camera,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              color: Color(0xff35CC2E),
                              child: Text(
                                action == 'edit' ? 'Edit Post' : 'Create Post',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  action == 'edit'
                                      ? editPost(id)
                                      : submitPost();
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
