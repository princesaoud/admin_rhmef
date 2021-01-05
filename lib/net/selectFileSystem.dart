import 'dart:io';

import 'package:admin_rhmef/constantes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SelectFileSys());
}

class SelectFileSys extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Upload Image en cours"),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          (imageUrl != null)
              ? Image.network(imageUrl)
              : Placeholder(
                  fallbackHeight: 200.0, fallbackWidth: double.infinity),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Text('Upload Image'),
            color: Colors.lightBlue,
            onPressed: () => uploadImage(),
          ),
          RaisedButton(
            child: Text('Valider Image'),
            color: Colors.green,
            onPressed: () => {Navigator.pop(context)},
          )
        ],
      ),
    );
  }

  getTokenDevice() {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String folderToken;
    _firebaseMessaging.getToken().then((token) {
      folderToken = token;
      print("token of the device is : $token");
    });
    return folderToken;
  }

  uploadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      image = await _picker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null) {
        //Upload to Firebase
        String imageName = prefs.getString(ConstantesValues.prefs_imageName);
        var snapshot =
            await _storage.ref().child('ActesProof/$imageName').putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl;
          prefs.setString("imageUrl", downloadUrl);
        });
      } else {
        print('No Path Received');
      }
    } else {
      print('Grant Permissions and try again');
    }
  }
}
